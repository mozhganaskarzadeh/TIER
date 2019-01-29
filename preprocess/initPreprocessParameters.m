function parameters = initPreprocessParameters()
%
%% initPreprocessParameters initalizes STIR parameters to defaults
% STIR - Simple Topographically Informed Regression
%
%
% Author:  Andrew Newman, NCAR/RAL
% Email :  anewman@ucar.edu
%
% Arguments:
%
%  Output:
%   
%   parameters, structure, structure holding all STIR preprocessing 
%   parameters
%

    %initialize all parameters to initial default value
    parameters.demFilterName = 'Daly';          %string
    parameters.demFilterPasses = 80;            %number
    parameters.minGradient = 0.003;             %km/km
    parameters.smallFacet = 500;                %km^2
    parameters.smallFlat = 1000;                %km^2
    parameters.narrowFlatRatio = 3.1;           %ratio
    parameters.coastSearchLength = 200;         %km
    parameters.layerSearchLength = 10;          %grid cells
    parameters.inversionHeight = 250;           %m

end            
