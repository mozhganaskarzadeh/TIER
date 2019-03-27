function finalNormSlope = updatePrecipSlope(nr,nc,mask,normSlope,validSlope,filterSize,filterSpread)
%
%% updatePrecipSlope updates the estimated slope (elevation lapse rate)
%                  of precipitation across the grid from the
%                  initial estimate
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
%   normslope, float, intial normalized slope estimate across grid
%   validSlope, integer, mask of valid regression estimated slopes
%   filterSize, integer, size of low-pass filter in grid points
%   filterSpread, float, variance of low-pass filter
%
%  Outputs:
%
%   finalNormSlope, structure, structure containing the final normalized 
%                              slope for all grid points for precip variables
%

    %use only points that had valid regression based slopes
    %filter and interpolate to entire domain 
    %ideally this is an improvement over a spatially constant default slope
    baseSlope = normSlope;
    baseSlope(validSlope~=1) = -999;
    domainMeanSlope = mean(mean(baseSlope(baseSlope ~= -999)));
    baseSlope(baseSlope == -999) = domainMeanSlope;

    %define a mesh of indicies for scattered interpolation of valid points
    %back to a grid
    y = 1:nr;
    x = 1:nc;
    [y2d,x2d] = meshgrid(x,y);

    %find valid grid points
    [i,j] = find(baseSlope > 0);
    %scattered interpolation using griddata
    interpBaseSlope = griddata(i,j,baseSlope(baseSlope>0),x2d,y2d,'linear');
    %fill missing values with nearest neighbor
    interpBaseSlope = fillNaN(interpBaseSlope,x2d,y2d);
    
    %define gaussian low-pass filter
    gFilter = fspecial('gaussian',[filterSize filterSize],filterSpread);

    %filter slope estimate
    filterSlope = imfilter(interpBaseSlope,gFilter);
    %set unused grid points to missing
    filterSlope(mask<0) = -999;

    %set output variable
    finalNormSlope = filterSlope;
    
end
