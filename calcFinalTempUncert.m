function finalUncert = calcFinalTempUncert(nr,nc,mask,symapUncert,slopeUncert,filterSize,filterSpread)
%
%% calcFinalTempUncert computes the final uncertainty for temperature variables
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
%   symapUncert, float, intiial symap uncertainty estimate across grid
%   slopeUncert, float, initial estimate of slope uncertainty across grid
%   filterSize, integer, size of low-pass filter in grid points
%   filterSpread, float, variance of low-pass filter
%
%  Outputs:
%
%   finalUncert, structure, structure containing total and relative
%                           uncertainty for met var

    %define local variable for spatial covariance calculation
    covWindow = 5;
    
    %define a mesh of indicies for scattered interpolation of valid points
    %back to a grid
    y = 1:nr;
    x = 1:nc;
    [y2d,x2d] = meshgrid(x,y);

    %find valid points
    [i,j] = find(~isnan(symap_uncert));
    %generate scattered interpolant for scattered interpolation
    FSymap = scatteredInterpolant(i,j,symapUncert(~isnan(symapUncert)),'linear','nearest');
    %find valid points
    [i,j] = find(slope_uncert > 0);
     %generate scattered interpolant for scattered interpolation
    FSlope = scatteredInterpolant(i,j,slopeUncert(slopeUncert>0),'linear','nearest');
    
    %scattered interpolation to structured grid
    interpSymap = FSymap(x2d,y2d);
    interpSlope = FSlope(x2d,y2d);
    
    %gaussian low-pass filter
    gFilter = fspecial('gaussian',[filterSize filterSize],filterSpread);
    
    %filter uncertainty estimates
    finalSymapUncert = imfilter(interpSymap,gFilter);
    finalSlopeUncert = imfilter(interpSlope,gFilter);
    %set nonvalid grid points to missing
    finalSymapUncert(mask==0) = -999;
    finalSlopeUncert(mask==0) = -999;
    
    %define values in output structure
    finalUncert.finalSymapUncert = finalSymapUncert;
    finalUncert.finalSlopeUncert = finalSlopeUncert;
    
    %estimate the total and relative uncertainty in physical units 
    baseSlopeUncert = finalSlopeUncert;
    baseSlopeUncert(mask==0) = NaN;
    %convert arrays to 1d for convenience
    symapUncert1d = reshape(finalSymapUncert,[nr*nc 1]);
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
    %reshape covariance back to 2d array
    localCov2d = reshape(localCov,[nr,nc]);
    
    %compute the total estimates 
    finalUncert.totalUncert = baseSlopeUncert+finalSymapUncert+2*sqrt(abs(localCov2d));
    finalUncert.relativeUncert = zeros(size(finalUncert.totalUncert))*NaN;
    
end
