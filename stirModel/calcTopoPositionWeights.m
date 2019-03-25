function topoPositionWeights = calcTopoPositionWeights(gridTopoPosition,topoPosMinDiff,topoPosMaxDiff,topoPosExp,stationTopoPos)
%
%% calcTopoPositionWeights computes weights for nearby stations as compared 
%  to the current grid point based on the differences in topographic 
%  position as in Daly et al. (2007), JAMC
%
% Author:  Andrew Newman
%
%
% Arguments:
%
%  Input:
%
%   gridTopoPosition, float, distance to coast of current grid point
%   stationTopoPos, float, vector of topographic position of nearby stations
%   nearStationInds, integer, vector of nearby station indicies
%
%  Output:
%   
%   topoPositionWeights, float, vector holding topographic position weights
%                               for nearby stations
%

    %initialize topographic position vector
    topoPositionWeights = zeros(length(stationTopoPos),1);
    %compute topographic position difference
    topoDiff = abs(stationTopoPos-gridTopoPosition);
    %check if any differences are below min, set to 1 weight
    topoPositionWeights(topoDiff<=topoPosMinDiff) = 1.0;
    %if differences are in between max and min, compute using linear decay
    topoPositionWeights(topoDiff>topoPosMinDiff) = 1./((topoDiff(topoDiff>topoPosMinDiff)/topoPosMinDiff).^topoPosExp);
    %if differences are larger than max, set to zero
    topoPositionWeights(topoDiff>topoPosMaxDiff) = 0.0;
    %normalize topographic position weights
    topoPositionWeights = topoPositionWeights./sum(topoPositionWeights);

end