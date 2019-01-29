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
    grid.dx = ncread(gridName,'dx')/1000; %convert m to km
    %read valid grid point mask
    grid.mask = ncread(gridName,'mask');
    %read DEM
    grid.dem = ncread(gridName,'elev');


    %set grid size variables
    [grid.nr,grid.nc] = size(grid.lat);


end
