function linearFit = calcWeightedRegression(stationElev,stationVar,stationWeights)
%
%% calcWeightedRegression computes a weighted linear regression of station
%  data against elevation.  Weight vector determines weight of each station
%  in the regression.  Here they are computed as the combination of the
%  component geophysical weights (e.g. coastal, layer, SYMAP).  Following
%  Daly et al. (1994,2002)
%
% Author:  Andrew Newman
%
%
% Arguments:
%
%  Input:
%
%   stationElev, float, vector of elevation of nearby stations
%   stationDist, float, vector of distance to nearby stations
%   stationVar, float, vector containing meteorological variable values from
%                  stations
%   stationWeights, float,vector of station weights
%
%  Output:
%   
%   linearFit, float, vector holding the two coefficients of the weighted
%                     linear regression
%

    %create weighted linear regression matricies
    n = length(stationElev);
    X = [ones(size(stationElev)) stationElev];
    W = eye(n,n);
    diagInd = 1:n;
    inds = sub2ind([n,n],diagInd,diagInd);
    W(inds) = stationWeights;

    %compute weighted linear regression
    linearFit = (((X'*W*X)^-1)*X'*W*stationVar)';
    
    %change order of coefficients for convenience
    linearFit = circshift(linearFit,-1,2);

end