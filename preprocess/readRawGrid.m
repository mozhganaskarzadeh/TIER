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
        %determine rough estimate of grid distance 
        %some small increment of lat and lon
        inc = 0.1; 
        %grid lower left lat,lon
        startLon = ncread(gridName,'startx'); 
        startLat = ncread(gridName,'starty');
        %distance between two points in m
        gridDist = distance(startLat,startLon,startLat+inc,startLon+inc,referenceEllipsoid('wgs84'));
        kmPerLat = gridDist/sqrt(inc*inc*2)/1000;
        
        %grid distance in km roughly
        grid.dx = grid.dx*kmPerLat;
        
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
