function inputStations = readInputStations(controlVars)
% 
%% readInputStations reads the input point station metadata
% and station data for STIR
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
%  stationFileList, string, the name of the station metadata file
%  stationDataPath, string, path to location of station data
%  controlVars, structure, structure holding control variables
%
% Output:
%
%  inputStations, structure, structure holding input station data, metdata, etc
%

    %open station list file
    fid = fopen(controlVars.stationFileList);
    %read station list with meta data
    inputStations.meta = textscan(fid,'%s %f %f %f %d %f %d %f %s','delimiter',',','headerlines',2); 
    %close file
    fclose(fid);

    %set number of stations
    nSta = length(inputStations.meta{1});

    %convert elevation to km
    inputStations.meta{4} = inputStations.meta{4}/1000.0;

    %allocate inputStations structure
    inputStations.avgVar = zeros(nSta,1);
    
    if(strcmpi(controlVars.variableEstimated,'precip'))
        metVar = 'prcp';
    elseif(strcmpi(controlVars.variableEstimated,'tmax') || strcmpi(controlVars.variableEstimated,'tmin'))
        metVar = lower(controlVars.variableEstimated);
    end

    %read data
    for i = 1:nSta
        fprintf(1,'Loading: %s\n',char(inputStations.meta{1}(i)));
        %create file name string
        fname = sprintf('%s/%s.nc',controlVars.stationDataPath,char(inputStations.meta{1}(i)));

        %read station data
        inputStations.avgVar(i) = ncread(fname,metVar);
    end

end
