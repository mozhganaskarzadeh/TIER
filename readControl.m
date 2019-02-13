function controlVars = readControl(controlName)
%
%% readControl reads a text control file for STIR
% STIR - Simple Topographically Informed Regression
%
%
% Author:  Andrew Newman
%
%
% Arguments:
%
% Input:
%
%  controlName, string, the name of the grid file
%
% Output:
% 
%  controlVars, structure, stucture holding all control variables
%                           


    %open control file
    fid = fopen(controlName);
    %read data
    data = textscan(fid,'%s %s %s','headerlines',1,'delimiter',',');
    %close control file
    fclose(fid);
    
    %run through all lines in control file
    for i = 1:length(data{1})
        %test string name and place in appropriate named variable
        switch(strtrim(char(data{1}(i))))
            case 'gridName'
                controlVars.gridName = strtrim(char(data{2}(i)));
            case 'stationFileList'
                controlVars.stationFileList = strtrim(char(data{2}(i)));
            case 'stationDataPath'
                controlVars.stationDataPath = strtrim(char(data{2}(i)));
            case 'outputName'
                controlVars.outputName = strtrim(char(data{2}(i)));
            case 'parameterFile'
                controlVars.parameterFile = strtrim(char(data{2}(i)));
            case 'variableEstimated'
                controlVars.variableEstimated = strtrim(char(data{2}(i)));
            case 'climoMonth'
                controlVars.climoMonth = str2double(strtrim(char(data{2}(i))));
            case 'climoPeriodStart'
                controlVars.climoPeriodStart = strtrim(char(data{2}(i)));
            case 'climoPeriodEnd'
                controlVars.climoPeriodEnd = strtrim(char(data{2}(i)));
            case 'defaultTempLapse'
                controlVars.defaultTempLapse = strtrim(char(data{2}(i)));
            otherwise
                %throw error if unknown string
                error('Unknown control file option: %s',char(data{1}(i)));
        end
    end
    
end
