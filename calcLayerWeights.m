function layerWeights = calcLayerWeights(gridLayer,gridElev,stationLayer,stationElev,layerExp)
%
%% calcLayerWeights computes the weights of stations to the current grid
%  point.  Estimates a 2-layer atmosphere (inversion and free) based on
%  topography.  Helpful identifying inversion areas as defined in 
%  Daly et al. (2002, Climate Res.), section 7
%
% Author:  Andrew Newman
%
%
% Arguments:
%
%  Input:
%
%   gridLayer, float, grid layer for current grid point
%   gridElev, float, grid elevation for current grid point
%   stationLayer, integer, layer of nearby stations
%   stationElev, float, elevation of nearby stations
%   layerExp, float, STIR parameter; exponent in weighting function
%
%  Output:
%   
%   layerWeights, float, vector holding layer weights for nearby stations
%

    %find nearby stations that match the grid layer
    layerMatch = stationLayer==gridLayer;

    %initalize weight variable
    layerWeights = zeros(length(stationLayer),1);

    %set station weight in same layer to 1
    layerWeights(layerMatch) = 1.0;
    %compute weights for stations in other layer, based on vertical
    %distance difference
    layerWeights(~layerMatch) = 1./(abs(gridElev-stationElev(~layerMatch)+1.0).^layerExp);
    %no station in other layer can have a weight >= 1.0
    layerWeights(layerWeights>=1) = 0.99;
    %normalize weights
    layerWeights = layerWeights./sum(layerWeights);


end