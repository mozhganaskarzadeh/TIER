function parameters = readParameters(parameterFile,parameters)
%
%% readParameters reads a text parameter file for STIR
%  and overrides the default values if parameters are present
%  in parameter file
%
% STIR - Simple Topographically Informed Regression
%
%
% Author:  Andrew Newman, NCAR/RAL
% Email:   anewman@ucar.edu
%
% Arguments:
%
% Input:
%
%  parameterFile, string, the name of the STIR parameter file
%  parameters, structure, structure holding all STIR parameters
%
% Output:
%
%  parameters, structure, structure holding all STIR parameters

%

    %open parameter file
    fid = fopen(parameterFile);
    %read data
    data = textscan(fid,'%s %s %s','headerlines',1,'delimiter',',');
    %close control file
    fclose(fid);
    
    %run through all lines in parameter file
    for i = 1:length(data{1})
        %test string name and place in appropriate named variable
        switch(char(data{1}(i)))
            case('nMaxNear')
                %maximum number of nearby stations to consider
                parameters.nMaxNear = str2double(strtrim(data{2}(i)));
            case('nMinNear')
                %minimum number of nearby stations needed for slope regression
                parameters.nMinNear = str2double(strtrim(data{2}(i)));
            case('maxDist')
                %maximum distance to consider stations
                parameters.maxDist = str2double(strtrim(data{2}(i)));
            case('minSlope')
                %minimum valid slope value (normalized for precipitation, physical units for temperature)
                parameters.minSlope = str2double(strtrim(data{2}(i)));
            case('maxInitialSlope')
                %maximum valid initial pass normalized slope for precipitation
                parameters.maxInitialSlope = str2double(strtrim(data{2}(i)));
            case('maxFinalSlope')
                %maximum valid final adjusted normalized slope for precipitation
                parameters.maxFinalSlope = str2double(strtrim(data{2}(i)));
            case('maxSlopeLower')
                %maximum valid slope for temperature in lower atmospheric layer (inversion layer, allows for strong inversions)
                parameters.maxSlopeLower = str2double(strtrim(data{2}(i)));
            case('maxSlopeUpper')
                %maximum valid slope for temperature in upper layer (free atmosphere, up to isothermal allowed)
                parameters.maxSlopeUpper = str2double(strtrim(data{2}(i)));
            case('defaultSlope')
                %default slope value (normalized for precipitation, physical units for temperature)
                parameters.defaultSlope = str2double(strtrim(data{2}(i)));
            case('topoPosMinDiff')
                %minimum elevation difference used to adjust topographic position weights
                parameters.topoPosMinDiff = str2double(strtrim(data{2}(i)));
            case('topoPosMaxDiff')
                %maximum elevation difference for stations to receive topographic position weighting
                parameters.topoPosMaxDiff = str2double(strtrim(data{2}(i)));
            case('topoPosExp')
                %exponent to adjust topographic position weighting function
                parameters.topoPosExp = str2double(strtrim(data{2}(i)));
            case('coastalExp')
                %exponent to adjust distance to coast weighting function
                parameters.coastalExp = str2double(strtrim(data{2}(i)));
            case('layerExp')
                %exponent to adjust atmospheric layer weighting function
                parameters.layerExp = str2double(strtrim(data{2}(i)));
            case('distanceWeightScale')
                %scale parameter in Barnes (1964) distance weighting function
                parameters.distanceWeightScale = str2double(strtrim(data{2}(i)));
            case('distanceWeightExp')
                %exponent in Barnes (1964) distance weighting function
                parameters.distanceWeightExp = str2double(strtrim(data{2}(i)));
            case('maxGrad')
                %maximum allowable normalized precipitation slope gradient between grid cells
                parameters.maxGrad = str2double(strtrim(data{2}(i)));
            case('bufferSlope')
                %a buffer parameter when computing precipitaiton slope feathering
                parameters.bufferSlope = str2double(strtrim(data{2}(i)));
            case('minElev')
                %minimum elevation considered when feathering precipitation
                parameters.minElev = str2double(strtrim(data{2}(i)))/1000; %convert m to km
            case('minElevDiff')
                %minimum elevation difference across precipitation considered for feathering precipitation
                parameters.minElevDiff = str2double(strtrim(data{2}(i)))/1000; %convert m to km
            case('filterSize')
                %size of low pass filter (grid points) used in computing updated slopes and uncertainty estimates
                parameters.filterSize = str2double(strtrim(data{2}(i)));
            case('filterSpread')
                %spread of low-pass filter power used in computing updated slopes and uncertainty estimates
                parameters.filterSpread = str2double(strtrim(data{2}(i)));
            case('covWindow')
                %window for local covariance calculation for the SYMAP and slope uncertainty components.  Used in the final uncertainty estimation routine
                parameters.covWindow = str2double(strtrim(data{2}(i)));
            otherwise
                %throw error if unknown string
                error('Unknown parameter name : %s',char(data{1}(i)));
        end
    end
end            
