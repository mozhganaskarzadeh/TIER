%% driver for the Simple Topographically Informed Regression (STIR) tool

% this tool is built on the concept that geophyiscal attributes contain
% information useful to predict the spatial distribution of meteorological
% variables (e.g. Daly et al. 1994,2002,2007,2008; Thornton et al. 1999; 
% Clark and Slater 2006; Carrera-Hernandez and Gaskin 2007; Tobin et al.
% 2011; Bardossy and Pegram 2013; Newman et al. 2015).

% A pre-processed DEM file (see stirPreprocessing.m) and input station data
% are used to create monthly climatological meteorological fields over a
% domain.  
%
%
% Author: Andy Newman, NCAR/RAL
% Email : anewman@ucar.edu
% 
% License: 
%
%
% %
% 
%User determines the controlName
controlName = input('Enter the name of your control file: ', 's');

%read control file
controlVars = readControl(controlName);

%read grid file
grid = readGrid(controlVars.gridName);
    
%initalize parameters to default values
parameters = initParameters(controlVars.variableEstimated);

%read user defined STIR parameter file
parameters = readParameters(controlVars.parameterFile,parameters);

%allocate space for output variables
metGrid = allocateMetVars(grid.nr,grid.nc);

%read input station data
inputStations = readInputStations(controlVars);

%if temperature and a gridded default slope file is specified, read it
if(strcmpi(controlVars.variableEstimated,'tmax') && ~isempty(controlVars.defaultTempLapse))
    tempDefaultLapse = ncread(controlVars.defaultTempLapse,'tmaxLapse');
elseif(strcmpi(controlVars.variableEstimated,'tmin') && ~isempty(controlVars.defaultTempLapse))
    tempDefaultLapse = ncread(controlVars.defaultTempLapse,'tminLapse');
end

%loop through all grid points and perform regression
for y = 1:grid.nr
    fprintf(1,'Row: %d of %d\n',y,grid.nr);
    for x = 1:grid.nc
%for y = 35
%    for x = 348
        if(grid.mask(y,x) > 0)
            %find nearby stations to current grid point
            nearStations = getNearStations(inputStations.meta{2},inputStations.meta{3},inputStations.meta{5},grid.lat(y,x),...
                                           grid.lon(y,x),grid.aspect(y,x),parameters.nMaxNear,parameters.maxDist);

            %compute coastal distance weights
            coastWeights.near = calcCoastWeights(grid.distToCoast(y,x),inputStations.meta{6}(nearStations.nearStationInds));
            coastWeights.aspect = calcCoastWeights(grid.distToCoast(y,x),inputStations.meta{6}(nearStations.aspectStationInds));

            %compute topographic position weights
            topoPositionWeights.near = calcTopoPositionWeights(grid.topoPosition(y,x),parameters.topoPosMinDiff,parameters.topoPosMaxDiff,...
                                                          parameters.topoPosExp,inputStations.meta{8}(nearStations.nearStationInds));
            topoPositionWeights.aspect = calcTopoPositionWeights(grid.topoPosition(y,x),parameters.topoPosMinDiff,parameters.topoPosMaxDiff,...
                                                          parameters.topoPosExp,inputStations.meta{8}(nearStations.aspectStationInds));

            %compute layer weights
            layerWeights.near = calcLayerWeights(grid.layerMask(y,x),grid.dem(y,x),inputStations.meta{7}(nearStations.nearStationInds),...
                                            inputStations.meta{3}(nearStations.nearStationInds),parameters.layerExp);
            layerWeights.aspect = calcLayerWeights(grid.layerMask(y,x),grid.dem(y,x),inputStations.meta{7}(nearStations.aspectStationInds),...
                                            inputStations.meta{3}(nearStations.aspectStationInds),parameters.layerExp);

            %compute SYMAP weights
            symapWeights.near = calcSymapWeights(nearStations.staDist(nearStations.nearStationInds),nearStations.staAngles(nearStations.nearStationInds),...
                                            parameters.distanceWeightScale,parameters.maxDist);
            symapWeights.aspect = calcSymapWeights(nearStations.staDist(nearStations.aspectStationInds),nearStations.staAngles(nearStations.aspectStationInds),...
                                            parameters.distanceWeightScale,parameters.maxDist);

            %compute final weights
            finalWeights.near = calcFinalWeights(controlVars.variableEstimated,symapWeights.near,coastWeights.near,...
                                                 topoPositionWeights.near,layerWeights.near);
            finalWeights.aspect = calcFinalWeights(controlVars.variableEstimated,symapWeights.aspect,coastWeights.aspect,...
                                                   topoPositionWeights.aspect,layerWeights.aspect);

            %compute first pass met field on grid
            if(strcmpi(controlVars.variableEstimated,'precip'))
                %compute met fields at current grid point for precipitation
                metPoint = calcPrecip(parameters,grid.dem(y,x),parameters.defaultSlope,finalWeights.near,finalWeights.aspect,...
                                      symapWeights.near,inputStations.meta{4}(nearStations.nearStationInds),inputStations.meta{4}(nearStations.aspectStationInds),...
                                      inputStations.avgVar(nearStations.nearStationInds),inputStations.avgVar(nearStations.aspectStationInds));
            elseif(strcmpi(controlVars.variableEstimated,'tmax') || strcmpi(controlVars.variableEstimated,'tmin'))
                %compute met fields at current grid point for temperature
                metPoint = calcTemp(parameters,dem.gridElev,defaultSlope,finalWeights,finalWeightsAspect,...
                                      symapWeights.near,stationElevNear,stationElevAspect,stationVarNear,stationVarAspect);
            end
            
            %set metGrid values for current grid point
            metGrid.rawField(y,x)        = metPoint.rawField;
            metGrid.intercept(y,x)       = metPoint.intercept;
            metGrid.slope(y,x)           = metPoint.slope;
            metGrid.normSlope(y,x)       = metPoint.normSlope;
            metGrid.symapField(y,x)      = metPoint.symapField;
            metGrid.symapElev(y,x)       = metPoint.symapElev;
            metGrid.symapUncert(y,x)     = metPoint.symapUncert;
            metGrid.slopeUncert(y,x)     = metPoint.slopeUncert;
            metGrid.normSlopeUncert(y,x) = metPoint.normSlopeUncert;
            metGrid.validRegress(y,x)    = metPoint.validRegress;
            
        end %valid mask check
    end %end x-loop
end     %end y-loop
    
%%
%update and compute final fields conditioned on met variable
if(strcmpi(controlVars.variableEstimated,'precip'))
    %re-compute slope estimate
    finalNormSlope = updatePrecipSlope(grid.nr,grid.nc,grid.mask,metGrid.normSlope,metGrid.validRegress,parameters.filterSize,parameters.filterSpread);
    
    %compute final field value
    %feather precipitation generally following Daly et al. (1994)
    metGrid.finalField = featherPrecip(parameters,grid.nr,grid.nc,grid.dx,grid.dem,grid.mask,finalNormSlope,metGrid.symapField,metGrid.symapElev);
    
    %compute final uncertainty estimate
    finalUncert = calcFinalPrecipUncert(grid.nr,grid.nc,grid.mask,metGrid.symapUncert,metGrid.normSlopeUncert,metGrid.finalField,parameters.filterSize,parameters.filterSpread,parameters.covWindow);
    
    %set metGrid variables
    metGrid.totalUncert = finalUncert.totalUncert;
    metGrid.relUncert = finalUncert.relativeUncert;
    metGrid.finalSlope = finalNormSlope.*metGrid.finalField;
    

elseif(strcmpi(controlVars.variableEstimated,'tmax') || strcmpi(controlVars.variableEstimated,'tmin'))
    %re-compute slope estimate
    metGrid.finalSlope = updateTempSlope(grid.nr,grid.nc,grid.mask,grid.layerMask,metGrid.slope,metGrid.defaultSlope,metGrid.validRegress,parameters.minSlope,...
                                 parameters.maxSlopeLower,metGrid.maxSlopeUpper,parameters.filterSize,parameters.filterSpread);

    %compute final field estimate
    metGrid.finalField = calcFinalTemp(grid.dem,grid.mask,metGrid.symapElev,metGrid.symapField,metGrid.finalSlope);
    
    %compute final uncertainty estimate
    finalUncert = calcFinalTempUncert(grid.nr,grid.nc,grid.mask,metGrid.symapUncert,metGrid.slopeUncert,parameters.filterSize,parameters.filterSpread,parameters.covWindow);

end


%output
saveOutput(controlVars.outputName,controlVars.variableEstimated,metGrid);
