function grid = readGrid(gridName)
% 
%% readGrid reads a netcdf grid file for the STIR code
% STIR - Simple Topographically Informed Regression
%
% Arguments:
%
% Input:
%
%  gridName, string, the name of the grid file
%
% Output:
%
%  grid, structure, structure holding DEM, geophysical attributes
%                   and related variables
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
 
    %read latitude and longitude
    grid.lat = ncread(gridName,'latitude');
    grid.lon = ncread(gridName,'longitude');
    %grid spacing
    grid.dx = ncread(gridName,'dx')/1000; %convert m to km
    %read valid grid point mask
    grid.mask = ncread(gridName,'mask');
    %read DEM
    grid.dem = ncread(gridName,'elev');
    %read smoothed DEM
    grid.smoothDem = ncread(gridName,'smooth_elev');
    %read distance to coast
    grid.distToCoast = ncread(gridName,'dist_to_coast');
    %read inversion layer
    grid.layerMask = ncread(gridName,'inversion_layer');
    %read topographic position
    grid.topoPosition = ncread(gridName,'topo_position');

    %convert DEM to km
    grid.dem = grid.dem/1000.0;

    %read slope aspect
    grid.aspect = ncread(gridName,'aspect');
    %double check missing data points, reset very low DEM values to missing
    grid.aspect(grid.dem < -100) = -999;

    %set grid size variables
    [grid.nr,grid.nc] = size(grid.lat);


end
