function finalWeights = calcFinalWeights(varEstimated,symapWeights,coastWeights,topoPositionWeights,layerWeights)
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
%   varEstimated, string, met variable being estimated
%   symapWeights, float, vector of SYMAP weights
%   coastWeights, float, vector of distance to coast weights
%   topoPositionWeights, float, vector of topographic position weights
%   layerWeights, float, vector of inversion layer weights
%
%  Output:
%   
%   finalWeights, float, vector holding final weights for nearby stations
%
    %inversion layer and topographic position weighting (layerWeights 
    %and topoPosition) not used for precipitation
    if(strcmpi(varEstimated,'precip'))
        finalWeights = symapWeights.*coastWeights;
    elseif(strcmpi(varEstimated,'tmax') || strcmpi(varEstimated,'tmin'))
        finalWeights = symapWeights.*coastWeights.*topoPositionWeights.*layerWeights;
    else
        error('Unrecognized variable: %s',varEstimated);
    end
    %normalize final weights
    finalWeights = finalWeights./sum(finalWeights);

    %prevent badly conditioned weight matrices in the regression
    %set minium weight to a small number that is still large enough for 
    %numerics to compute
    finalWeights(finalWeights<1e-6) = 1e-6;
    
end