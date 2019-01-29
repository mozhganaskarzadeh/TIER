function finalUncert = calcFinalPrecipUncert(nr,nc,mask,symapUncert,slopeUncert,finalVar,filterSize,filterSpread)
%
%% featherPrecip updates the estimated precipitation field to remove sharp,
%                potentially unrealistic gradients due primarily do to
%                slope aspect processing. Generally follows Daly et al.
%                (1994).  This is the final precipitation processing step.
%
% Author: Andrew Newman NCAR/RAL
% Email : anewman@ucar.edu
%
% Arguments:
%
%  Inputs:
%
%   nr, integer,   number of rows in grid
%   nc, integer,   number of columns in grid
%   mask, integer, mask of valid grid points
%   symapUncert, float, symap precipitation uncertainty estimate (mm timestep-1)
%   slopeUncert, float,    estimated uncertainty of slope (elev lapse rate)
%                          in normalized space
%   finalVar, float,      final variable estimate (precip here)
%   filterSize, integer, size of low-pass filter in grid points
%   filterSpread, float, variance of low-pass filter
%
%  Outputs:
%
%   finalUncert, structure, structure containing the final components
%                           and the total and relative precipitation 
%                           uncertainty estimates
%

    %define local variable for spatial covariance calculation
    covWindow = 5;

    %use only points that had valid uncertainty estimates from the base
    %SYMAP interpolation or the weighted regression, then
    %filter and interpolate to entire domain 
    %this estimates uncertainty at each grid point from points where we
    %actually have initial estimates
    %also smooths out high-frequency noise
    
    %define a mesh of indicies for scattered interpolation of valid points
    %back to a grid
    y = 1:nr;
    x = 1:nc;
    [y2d,x2d] = meshgrid(x,y);

    %find valid symapUncert points
    [i,j] = find(~isnan(symapUncert));
    %scattered interpolation 
    fSymap = scatteredInterpolant(i,j,symapUncert(~isnan(symapUncert)),'linear','nearest');
    %find valid slopeUncert points
    [i,j] = find(slopeUncert > 0);
    %scattered interpolation
    fSlope = scatteredInterpolant(i,j,slopeUncert(slopeUncert>0),'linear','nearest');
    
    %use scattered interpolants to compute interpolated uncertainty
    %estimates
    interpSymap = fSymap(x2d,y2d);
    interpSlope = fSlope(x2d,y2d);
    
    %generate gaussian low-pass filter
    gFilter = fspecial('gaussian',[filterSize filterSize],filterSpread);
    
    %filter uncertainty estimates
    finalSymapUncert = imfilter(interpSymap,gFilter);
    finalSlopeUncert = imfilter(interpSlope,gFilter);
    %set nonvalid grid points to missing
    finalSymapUncert(mask==0) = -999;
    finalUncert.finalSlopeUncert(mask==0) = -999;
    
    %define values in output structure
    finalUncert.finalSymapUncert = finalSymapUncert;
    finalUncert.finalSlopeUncert = finalSlopeUncert;
    
    %estimate the total and relative uncertainty in physical units 
    %(mm timestep-1)
    %compute slope in physical space
    size(finalSlopeUncert)
    size(finalVar)
    baseSlopeUncert = (finalSlopeUncert.*finalVar);
    baseSlopeUncert(mask==0) = NaN;
    
    %convert arrays to 1d for convenience
    symapUncert1d = reshape(filterSymapUncert,[nr*nc 1]);
    slopeUncert1d = reshape(baseSlopeUncert,[nr*nc 1]);
    
    %define a local covariance vector
    localCov = zeros(length(symapUncert1d),1)*NaN;

    %step through each grid point and estimate the local covariance between
    %the two uncertainty components
    %covariance influences the total combined estimate
    for i = (covWindow+1):length(symapUncert1d)-covWindow
        if(~isnan(symapUncert1d(i)))
            %covariance computation
            c = cov(symapUncert1d(i-covWindow:i+covWindow),slopeUncert1d(i-covWindow:i+covWindow),'partialrows');
            localCov(i) = c(2,1);
        end
    end
    %fill border grid points with nearby values
    localCov(1:covWindow) = localCov(covWindow+1);
    localCov(length(localCov)-(covWindow-1):length(localCov)) = localCov(length(localCov)-covWindow);
    %reshape back to 2-dimensional array
    localCov2d = reshape(localCov,[nr,nc]);
    
    %compute the total estimates 
    finalUncert.totalUncert = baseSlopeUncert+filter_symap_uncert+2*sqrt(abs(localCov2d));
    finalUncert.relativeUncert = finalUncert.totalUncert./finalVar;
    
end