function parameters = initParameters(varEstimated)
%
%% initParameters initalizes STIR parameters to defaults
% STIR - Simple Topographically Informed Regression
%
%
% Author:  Andrew Newman
%
%
% Arguments:
%
%  Output:
%   
%   parameters, structure, structure holding all STIR parameters
%

    %initialize all parameters to initial default value
    parameters.nMaxNear = 7;                  %number
    parameters.nMinNear = 3;                  %number
    parameters.maxDist = 250;                 %km
    parameters.minSlope = 0.5;                %normalized for precipitation
    parameters.maxInitialSlope = 4.25;        %normalized
    parameters.maxFinalSlope = 3.0;           %normalized
    parameters.maxSlopeLower = 0;             %K/km
    parameters.maxSlopeUpper = 20;            %K/km
    parameters.defaultSlope = 1.3;            %normalized
    parameters.topoPosMinDiff = 500;          %m
    parameters.topoPosMaxDiff = 5000;         %m
    parameters.topoPosExp = 0.75;             % -
    parameters.coastalExp = 1.0;              % -
    parameters.layerExp = 0.5;                % -
    parameters.distanceWeightScale = 16000;   % -
    parameters.distanceWeightExp = 2;         % -
    parameters.maxGrad = 2.5;                 % normalized slope per grid cell
    parameters.bufferSlope = 0.02;            % normalized
    parameters.minElev = 100;                 % m
    parameters.minElevDiff = 500;             % m
    parameters.filterSize = 60;               % grid cells
    parameters.filterSpread = 40;             % -

    %initialize variables based on meteorological variable being regressed
    if(strcmpi(varEstimated,'precip'))
        %precipitation specific initialization values here 
    elseif(strcmpi(varEstimated,'tmax') || strcmpi(varEstimated,'tmin'))
        %temperature specific initialization values here
        parameters.nMaxNear = 30;                 %number
        parameters.nMinNear = 3;                  %number
        parameters.maxDist = 300;                 %km
        parameters.minSlope = -10;                %K/km
        parameters.maxSlopeLower = 0;             %K/km
        parameters.maxSlopeUpper = 20;            %K/km
        parameters.defaultSlope = -5;             %normalized
        parameters.topoPosMinDiff = 0;            %m 
        parameters.topoPosMaxDiff = 500;          %m
        parameters.topoPosExp = 0.50;             % -
        parameters.coastalExp = 1.0;              % -
        parameters.layerExp = 4.0;                % -
        parameters.distanceWeightScale = 20000;   % - 
    endif
end            
