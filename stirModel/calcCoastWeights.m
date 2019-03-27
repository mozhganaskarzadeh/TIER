function coastWeights = calcCoastWeights(gridDistanceToCoast,stationDistanceToCoast,coastalExp)
%
%% calcCoastWeights computes weights for stations as compared to the 
%  current grid point based on the differences in coastal distance
%
% Author:  Andrew Newman
%
%
% Arguments:
%
%  Input:
%
%   gridDistanceToCoast, float, distance to coast of current grid point
%   stationDistanceToCoast, float, distance to coast for nearby stations
%
%  Output:
%   
%   coastWeights, float, vector holding coastal weights for nearby stations
%

    %define a tiny float
    tiny = 1e-5;

    %distance to coast weighting (e.g. Daly et al. 2002)
    coastWeights = 1.0./(abs(gridDistanceToCoast-stationDistanceToCoast)+tiny).^(coastalExp);
    %check for values > 1
    coastWeights(coastWeights>1) = 1.0;
    %normalize weights
    coastWeights = coastWeights./sum(coastWeights);

end
