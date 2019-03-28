function finalSlope = updateTempSlope(nr,nc,mask,gridLayer,slope,defaultSlope,validSlope,minSlope,maxSlopeLower,maxSlopeUpper,filterSize,filterSpread)
%
%% updateTempSlope updates the estimated slope (elevation lapse rate)
%                  of temperature variables across the grid from the
%                  initial estimate
%
% Arguments:
%
%  Inputs:
%
%   nr, integer,   number of rows in grid
%   nc, integer,   number of columns in grid
%   mask, integer, mask of valid grid points
%   slope, float, intiial slope estimate across grid
%   defaultSlope, float, default estimate of slope uncertainty across grid
%   validSlope, integer, mask of valid regression estimated slopes
%   minSlope     , float, minimum valid slope (STIR parameter)
%   maxSlopeLower, float, maximum lower layer valid slope (STIR parameter)
%   maxSlopeUpper, float, maximum upper layer valid slope (STIR parameter)
%   filterSize, integer, size of low-pass filter in grid points
%   filterSpread, float, variance of low-pass filter
%
%  Outputs:
%
%   finalSlope, structure, structure containing the final slope for all
%                          grid points for temp variables
%
% Author: Andrew Newman, NCAR/RAL
% Email : anewman@ucar.edu
% Postal address:
%     P.O. Box 3000
%     Boulder,CO 80307
% 
% Copyright (C) 2019 Andrew Newman
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.
%

    %use only points that had valid regression based slopes
    %filter and interpolate to entire domain 
    %ideally this is an improvement over initial default slope estimates
    baseSlope = slope;
    baseSlope(validSlope~=1) = -999;
    domainMeanSlope = mean(mean(baseSlope(baseSlope ~= -999)));
    baseSlope(baseSlope == -999) = domainMeanSlope;

    %define a mesh of indicies for scattered interpolation of valid points
    %back to a grid
    y = 1:nr;
    x = 1:nc;
    [y2d,x2d] = meshgrid(x,y);

    %perform 2 scattered interpolations to get final slope, one for layer 1,
    %one for layer2
    
    %find valid points for layer 1
    [i,j] = find(baseSlope >= minSlope & gridLayer == 1);
    %scattered interpolation using griddata
    interpSlopeLayer1 = griddata(i,j,baseSlope(baseSlope>= minSlope & gridLayer == 1),x2d,y2d,'linear');
    %fill missing values with nearest neighbor
    interpSlopeLayer1 = fillNaN(interpSlopeLayer1,x2d,y2d);
    
    %find valid points for layer 2
    [i,j] = find(baseSlope >= minSlope & gridLayer == 2);
    %scattered interpolation using griddata
    interpSlopeLayer2 = griddata(i,j,baseSlope(baseSlope>= minSlope & gridLayer == 2),x2d,y2d,'linear');
    %fill missing values with nearest neighbor
    interpSlopeLayer2 = fillNaN(interpSlopeLayer2,x2d,y2d);
    
    %define gaussian low-pass filter
    gFilter = fspecial('gaussian',[filterSize filterSize],filterSpread);

    %filter layer 1
    filterSlopeLayer1 = imfilter(interpSlopeLayer1,gFilter);

    %for valid points
    %check to see if new estimate is 
%    filterSlopeLayer1(filterSlopeLayer1 < -6 & mask > 0) = defaultSlope(filterSlopeLayer1 < -6 & mask > 0) + 1.5; %why was this done?

    %check for invalid slopes
    filterSlopeLayer1(filterSlopeLayer1 > maxSlopeLower) = maxSlopeLower;
    filterSlopeLayer1(filterSlopeLayer1 < minSlope) = minSlope;
    %set unused points to missing
    filterSlopeLayer1(mask<0) = -999;
    
    %filter layer 2
    filterSlopeLayer2 = imfilter(interpSlopeLayer2,gFilter);

    %for valid points
    %check to see if new estimate is 
%    filterSlopeLayer2(filterSlopeLayer2 < -6 & mask > 0) = defaultSlope(filterSlopeLayer2 <-6 & mask > 0) + 1.5;

    %check for invalid slopes
    filterSlopeLayer2(filterSlopeLayer2 > maxSlopeUpper) = maxSlopeUpper;
    filterSlopeLayer2(filterSlopeLayer2 < minSlope) = minSlope;
    %set unused points to missing
    filterSlopeLayer2(mask<0) = -999;
    
    %combine the two layer estimates into one complete grid
    finalSlope = filterSlopeLayer1;
    finalSlope(gridLayer == 2) = filterSlopeLayer2(gridLayer == 2);
    
end
