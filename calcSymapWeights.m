function symapWeights = calcSymapWeights(staDist,staAngles,distanceWeightScale,maxDist)
%
%% calcSymapWeights computes weights for nearby stations following the
%  concept of the SYMAP algorithm (Shepard 1984).  Uses Barnes (1964) type
%  distance weights instead of the exact SYMAP method.  Angular weighting
%  is from Shepard (1984).
%
% Author:  Andrew Newman, NCAR/RAL
% Email:   anewman@ucar.edu
%
%
% Arguments:
%
%  Input:
%
%   staDist, float, vector of station distances to current grid point
%   staAngles, float, vector of station angles from current grid point
%   distanceWeightScale, float, input STIR parameter
%   maxDist, float, input STIR parameter of maximum search distance
%
%  Output:
%   
%  symapWeights,float, vector holding SYMAP weights of nearby stations
%
    %set number of stations
    nMatch = length(staDist);
    
    %to radians
    toRad = pi/180.0;
    
    %compute mean from nearest N stations using Barnes (1964) type distance weights
    %Set the scale factor to depends on mean distance of nearby stations
    meanDist = mean(staDist);
    scale = distanceWeightScale*(meanDist/(maxDist));

    %compute initial distance weights
    distanceWeights = exp(-(staDist.^2/scale));

    %directional isolation (Shepard 1984)
    %set angular isolation weight variable
    angleWeight = zeros(nMatch,1);
    %run through stations compute angle and isolation from other stations
    for i = 1:nMatch
        cosThetaSta = zeros(nMatch,1);
        for j = 1:nMatch
            %angle of station in radians from next station
            cosThetaSta(j) = cos((staAngles(i)-staAngles(j))*toRad);
        end
        %total angular isolation weight
        angleWeight(i) = sum(distanceWeights(i)*(1-cosThetaSta));

    end
    
    %increment integer vector: 1 to nMatch 
    inds = 1:nMatch;
    
    %compute weights as a combination of distance and directional isolation
    symapWeights = distanceWeights.^2.*( 1+(angleWeight./sum(angleWeight(setxor(inds,i)))) );
    %normalize weights
    symapWeights = symapWeights./sum(symapWeights);

end