function distToCoast = calcDistToCoast(grid,searchLength)
%
%% calcDistToCoast computes the distance to the nearest ocean masked grid 
%  cell using the input grid DEM and mask.  Uses a search length of
%  searchLength km.  Any grid cells that do not have ocean within that
%  search length have the distanceToCoast set to searchLength.  Generally
%  follows Daly et al. (2003)
%
% Arguments:
%
% Input:
%
%  grid,     structure, the raw grid structure
%  searchLength, float, the maximum search distance to compute coastal
%                       distance
%
% Output:
% 
%  distToCoast, array, array of coastal distances for domain, computed at
%                      valid land pixels only
%                           
% Author: Andrew Newman, NCAR/RAL
% Email : anewman@ucar.edu
% Postal address:
%     P.O. Box 3000
%     Boulder,CO 80301
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

    %Note this is a time consuming routine as written.  There are likely
    %opportunities for speed-up for large domains.

    %print status
    fprintf(1,'Computing distance to coast\n');

    %find all land points in domain
    landPts = grid.mask > 0;
    %lat of land points
    latLand = grid.lat(landPts);
    %lon of land points
    lonLand = grid.lon(landPts);
    %how many land points
    lenLand = length(lonLand);
    %array indices of land points
    landInds = find(grid.mask > 0);

    %define ellipsoid
    %ellipse = referenceEllipsoid('wgs84');

    %convert searchLength to pixels
    searchLength = floor(searchLength/grid.dx);

    %define output variable, set to missing
    distToCoast = zeros(grid.nr,grid.nc)-999.0;

    %loop through all land points

    for pt = 1:lenLand
        %create i,j array index of current land point
        [i,j] = ind2sub([grid.nr,grid.nc],landInds(pt));

        %find range to search along rows using searchLength
        rRange = [max([1 i-searchLength]) min([i+searchLength grid.nr])];
        %find range to search along columns using searchLength
        cRange = [max([1 j-searchLength]) min([j+searchLength grid.nc])];
        %compute distance for entire search box (searchLength*searchLength
        %pixels)
    %    dists = distance(latLand(pt),lonLand(pt),lat(rRange(1):rRange(2),cRange(1):cRange(2)),lon(rRange(1):rRange(2),cRange(1):cRange(2)),ellipse,'kilometers');

        %find all (if any) ocean pixels
        demSub = grid.dem(rRange(1):rRange(2),cRange(1):cRange(2));
        oceanValid = grid.mask(rRange(1):rRange(2),cRange(1):cRange(2)) == -1;
        demSubValid = demSub(oceanValid);


        %compute distance along great-circle route
    %    dists = distance(latLand(pt),lonLand(pt),grid.lat(rRange(1):rRange(2),cRange(1):cRange(2)),grid.lon(rRange(1):rRange(2),cRange(1):cRange(2)));

        %if there are any ocean pixels
        if(~isempty(demSubValid))
            %subset lat and lon
            latSub = grid.lat(rRange(1):rRange(2),cRange(1):cRange(2));
            lonSub = grid.lon(rRange(1):rRange(2),cRange(1):cRange(2));
            latSubValid = latSub(oceanValid);
            lonSubValid = lonSub(oceanValid);

            dists = distance(latLand(pt),lonLand(pt),latSubValid,lonSubValid);
            %convert dists from arc length (degrees) to km (approximately)
            %about 60 nmi in 1 degree of arc length, 1 nm = 1.852 km
            dists = dists*60.0*1.852;

            %find nearest ocean pixels
            dists = sort(dists);
            distToCoast(i,j) = dists(1);
        end 

    end  %end land points loop

    %find maximum distance computed
    maxDist = max(distToCoast(grid.mask == 1));

    %set all non-computed valid land points to maxDist 
    distToCoast(grid.mask == 1 & distToCoast == -999) = maxDist;

end
