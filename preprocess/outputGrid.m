function outputGrid(controlVars,outGrid)
%
%% outputGrid saves the domain grid structure into a netcdf file
% Author: Andrew Newman NCAR/RAL
% Email : anewman@ucar.edu
%
% Arguments:
%
%  Input:
% 
%   controlVars, structure   , structure containing control variables
%   outGrid   , structure, structure containing processed domain grid and
%   geophysical attributes
%
%  Output:
% 
%    None


%print status
fprintf(1,'Outputting processed grid to netcdf file\n');

%first copy raw grid to output grid
%create command string
cmdString = sprintf('cp %s %s',char(controlVars.gridName),char(controlVars.outputName));
%execute command
system(cmdString);

%output smoothed elevation
nccreate(controlVars.outputName,'smooth_elev','Dimensions',{'x',outGrid.nr,'y',outGrid.nc});
ncwrite(controlVars.outputName,'smooth_elev',outGrid.aspects.smoothDEM);
ncwriteatt(controlVars.outputName,'smooth_elev','name','Smoothed DEM');
ncwriteatt(controlVars.outputName,'smooth_elev','long_name','Smoothed Digital Elevation Map');
ncwriteatt(controlVars.outputName,'smooth_elev','_FillValue',-999.0);
ncwriteatt(controlVars.outputName,'smooth_elev','units','m');

%output smoothed gradient terms for book keeping
%north - south graident
nccreate(controlVars.outputName,'gradient_n_s','Dimensions',{'x',outGrid.nr,'y',outGrid.nc});
ncwrite(controlVars.outputName,'gradient_n_s',outGrid.aspects.gradNorth);
ncwriteatt(controlVars.outputName,'gradient_n_s','name','N-S Gradient');
ncwriteatt(controlVars.outputName,'gradient_n_s','long_name','Smoothed North-South Gradient (North facing positive)');
ncwriteatt(controlVars.outputName,'gradient_n_s','_FillValue',-999.0);
ncwriteatt(controlVars.outputName,'gradient_n_s','units','km/km');

%west - east gradient
nccreate(controlVars.outputName,'gradient_w_e','Dimensions',{'x',outGrid.nr,'y',outGrid.nc});
ncwrite(controlVars.outputName,'gradient_w_e',outGrid.aspects.gradEast);
ncwriteatt(controlVars.outputName,'gradient_w_e','name','W-E Gradient');
ncwriteatt(controlVars.outputName,'gradient_w_e','long_name','Smoothed West-East Gradient (West facing positive');
ncwriteatt(controlVars.outputName,'gradient_w_e','_FillValue',-999.0);
ncwriteatt(controlVars.outputName,'gradient_w_e','units','km/km');

%output aspects
nccreate(controlVars.outputName,'aspect','Dimensions',{'x',outGrid.nr,'y',outGrid.nc});
ncwrite(controlVars.outputName,'aspect',outGrid.aspects.aspects);
ncwriteatt(controlVars.outputName,'aspect','name','integer aspect');
ncwriteatt(controlVars.outputName,'aspect','long_name','integer aspect: 1=N,2=E,...,5=Flat generally following Daly et al. 1994');
ncwriteatt(controlVars.outputName,'aspect','_FillValue',-999.0);
ncwriteatt(controlVars.outputName,'aspect','units','-');

%output distance to coast
nccreate(controlVars.outputName,'dist_to_coast','Dimensions',{'x',outGrid.nr,'y',outGrid.nc});
ncwrite(controlVars.outputName,'dist_to_coast',outGrid.distToCoast);
ncwriteatt(controlVars.outputName,'dist_to_coast','_FillValue',-999.0);
ncwriteatt(controlVars.outputName,'dist_to_coast','name','Distance to coast');
ncwriteatt(controlVars.outputName,'dist_to_coast','long_name','Distance to closest water point in DEM (e.g. Daly et al. 2003)');
ncwriteatt(controlVars.outputName,'dist_to_coast','units','km');

%output topographic position
nccreate(controlVars.outputName,'topo_position','Dimensions',{'x',outGrid.nr,'y',outGrid.nc});
ncwrite(controlVars.outputName,'topo_position',outGrid.positions.topoPosition);
ncwriteatt(controlVars.outputName,'topo_position','_FillValue',-999.0);
ncwriteatt(controlVars.outputName,'topo_position','name','Topographic Position');
ncwriteatt(controlVars.outputName,'topo_position','long_name','Grid point topographic position relative to nearby smoothed DEM cells following Daly et al. 2002');
ncwriteatt(controlVars.outputName,'topo_position','units','m');

%output inversion layer
nccreate(controlVars.outputName,'inversion_layer','Dimensions',{'x',outGrid.nr,'y',outGrid.nc});
ncwrite(controlVars.outputName,'inversion_layer',outGrid.positions.layerMask);
ncwriteatt(controlVars.outputName,'inversion_layer','_FillValue',-999.0);
ncwriteatt(controlVars.outputName,'inversion_layer','name','Atmospheric Layer');
ncwriteatt(controlVars.outputName,'inversion_layer','long_name','Simple two-layer atmospheric position (1=inversion, 2=free) from Daly et al. 2002');
ncwriteatt(controlVars.outputName,'inversion_layer','units','-');

end