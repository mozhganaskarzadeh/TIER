function grid = readRawGrid(gridName)
% 
%% readRawGrid reads a netcdf grid file for the STIR preprocessing code
% STIR - Simple Topographically Informed Regression
%
%
% Author:  Andrew Newman
% Email :  anewman@ucar.edu
%
% Arguments:
%
% Input:
%
%  gridName, string, the name of the grid file
%
% Output:
%
%  grid, structure, structure holding DEM and related variables
%

    %read latitude and longitude
    grid.lat = ncread(gridName,'latitude');
    grid.lon = ncread(gridName,'longitude');
    %grid spacing
    gridUnits = ncreadatt(gridName,'dx','units');
    if(strcmpi(gridUnits,'degrees'))
        grid.dx = ncread(gridName,'dx');
        %convert to km (roughly)
        
        %grid lower left lat,lon
        startLon = ncread(gridName,'startx'); 
        startLat = ncread(gridName,'starty');

        %find grid point distance in km approximately
        gridDist = distance(startLat,startLon,startLat+grid.dx,startLon+grid.dx);
        kmPerLat = rad2km(deg2rad(gridDist));
        
        %grid distance in km roughly
        grid.dx = (grid.dx*kmPerLat)/sqrt(gridDist.^2);
        
    elseif(strcmpi(gridUnits,'km'))
        grid.dx = ncread(gridName,'dx');
    elseif(strcmpi(gridUnits,'m'))
        grid.dx = ncread(gridName,'dx')/1000; %convert m to km
    else
        error('Unknown grid dx units: %s\n',gridUnits);
    end
    %read valid grid point mask
    grid.mask = ncread(gridName,'mask');
    %read DEM
    grid.dem = ncread(gridName,'elev');


    %set grid size variables
    [grid.nr,grid.nc] = size(grid.lat);


end
