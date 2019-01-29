function controlVars = readPreprocessControl(controlName)
%
%% readPreprocessControl reads a text control file for STIR preprocessing
% STIR - Simple Topographically Informed Regression
%
%
% Author:  Andrew Newman, NCAR/RAL
% Email :  anewman@ucar.edu
%
% Arguments:
%
% Input:
%
%  controlName, string, the name of the grid file
%
% Output:
% 
%  controlVars, structure, stucture holding all preprocessing control variables
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
            case 'rawGridName'
                controlVars.gridName = strtrim(char(data{2}(i)));
            case 'outputGridName'
                controlVars.outputName = strtrim(char(data{2}(i)));
            case 'preprocessParameterFile'
                controlVars.parameterFile = strtrim(char(data{2}(i)));
            case 'stationPath'
                controlVars.stationPath = strtrim(char(data{2}(i)));
            otherwise
                %throw error if unknown string
                error('Unknown control file option: %s',char(data{1}(i)));
        end
    end
    
end
