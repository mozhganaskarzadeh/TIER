function nearStations = getNearStations(staLat,staLon,staAspect,gridLat,gridLon,gridAspect,nMatch,maxDist)
%
%% getNearStations finds nearby stations for current grid point
%
%
% Author:  Andrew Newman
%
%
% Arguments:
%
%  Input:
%
%   yPt, integer, y counter for current grid point
%   xPt, integer, x counter for current grid point
%   staLat, float, vector of station lat
%   staLon, float, vector of station lon
%   staAspect, integer, vector of station integer aspects
%   grid, structure, structure containing grid
%   nMatch, integer, value of maximum number of stations to search for
%   maxDist, float, value of maximum radius to search for stations
%
%  Output:
%
%   nearStations, structure, structure containing indicies for stations
%   within search radius and those within that search
%   area on the same topographic aspect as the current grid point
%
%

    %comput distance to current grid point for all stations
    [staDist, staAngles] = distance(staLat,staLon,gridLat,gridLon,wgs84Ellipsoid);
    staDist = staDist/1000.0; %convert to km

    %get station indices from sorted distance (nearMatch)
    [~,distSort] = sort(staDist);
    nearMatch = distSort(1:nMatch);

    %find stations on same topographic aspect as current grid point
    matchAspect = find(staAspect == gridAspect);
    %get indicies of stations on same topographic aspect
    [~,matchAspectSort]= sort(staDist(matchAspect));
    %take nMatch stations on same aspect with consideration of distance
    %from grid point
    stationInds = matchAspect(matchAspectSort(1:nMatch));
    %now cull list based on distance from grid point
    matchDist = staDist(stationInds) <= maxDist;
    %finalize station indices
    aspectStationInds = stationInds(matchDist);

    %set output structure
    nearStations.staDist = staDist;
    nearStations.staAngles = staAngles;
    nearStations.nearStationInds = nearMatch;
    nearStations.aspectStationInds = aspectStationInds;
    
end            
