function finalUncert = calcFinalTempUncert(nr,nc,mask,symapUncert,slopeUncert,filterSize,filterSpread,covWindow)
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
%   covWindow, float, size (grid points) of covariance window
%
%  Outputs:
%
%   finalUncert, structure, structure containing total and relative
%                           uncertainty for met var

    %define a mesh of indicies for scattered interpolation of valid points
    %back to a grid
    y = 1:nr;
    x = 1:nc;
    [y2d,x2d] = meshgrid(x,y);

    %find valid points for symap uncertainty
    [i,j] = find(~isnan(symap_uncert));
    %scattered interpolation using griddata
    interpSymap = griddata(i,j,symapUncert(~isnan(symapUncert)),x2d,y2d,'linear');
    %fill missing values with nearest neighbor
    interpSymap = fillNaN(interpSymap,x2d,y2d);
    
    %find valid points for slope uncertaintty
    [i,j] = find(slope_uncert > 0);
    %scattered interpolation using griddata
    interpSlope = griddata(i,j,slopeUncert(slopeUncert>0),x2d,y2d,'linear');
    %fill missing values with nearest neighbor
    interpSlope = fillNaN(interpSlope,x2d,y2d);
    
    %gaussian low-pass filter
    gFilter = fspecial('gaussian',[filterSize filterSize],filterSpread);
    
    %filter uncertainty estimates
    finalSymapUncert = imfilter(interpSymap,gFilter);
    finalSlopeUncert = imfilter(interpSlope,gFilter);
    
    %replace nonvalid mask points with NaN
    finalSymapUncert(mask<0) = NaN;
    finalSlopeUncert(mask<0) = NaN;
    
    %estimate the total and relative uncertainty in physical units 

    %define a local covariance vector
    localCov = zeros(size(finalSymapUncert))*NaN;

    %step through each grid point and estimate the local covariance between
    %the two uncertainty components using covWindow to define the size of the local covariance estimate
    %covariance influences the total combined estimate
    for i = 1:nr
        for j = 1:nc
            %define indicies aware of array bounds
            iInds = [max([1 i-covWindow]),min([nr i+covWindow])];
            jInds = [max([1 j-covWindow]),min([nc j+covWindow])];

            %compute local covariance using selection of valid points
            %get windowed area
            subSymap = finalSymapUncert(iInds(1):iInds(2),jInds(1):jInds(2));
            subSlope = finalSlopeUncert(iInds(1):iInds(2),jInds(1):jInds(2));
            %compute covariance for only valid points in window
            c = cov(subSymap(~isnan(subSymap)),subSlope(~isnan(subSlope)),0);
            %pull relevant value from covariance matrix
            localCov(i,j) = c(1,length(c(1,:)));
        end
    end

    %compute the total estimates 
    finalUncert.totalUncert = baseSlopeUncert+finalSymapUncert+2*sqrt(abs(localCov));
    finalUncert.relativeUncert = zeros(size(finalUncert.totalUncert))*NaN;

    %set novalid gridpoints to missing
    finalSymapUncert(mask<0) = -999;
    finalSlopeUncert(mask<0) = -999;
    finalUncert.totalUncert(mask<0) = -999;
    finalUncert.relativeUncert(mask<0) = -999;    

    %define components in output structure
    finalUncert.finalSymapUncert = finalSymapUncert;
    finalUncert.finalSlopeUncert = finalSlopeUncert;


end
