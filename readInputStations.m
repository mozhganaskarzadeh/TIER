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

    %define local variable days per month
    %February averages ~28.25 days in a long-term sense including leap days
    monthDays = [31 28.25 31 30 31 30 31 31 30 31 30 31];
    
    %open station list file
    fid = fopen(controlVars.stationFileList);
    %read station list with meta data
    inputStations.meta = textscan(fid,'%s %f %f %f %f %f %d %f %d %f %s','delimiter',',','headerlines',2); 
    %close file
    fclose(fid);

    %set number of stations
    nSta = length(inputStations.meta{1});

    %convert elevation to km
    inputStations.meta{4} = inputStations.meta{4}/1000.0;

    %create a date array
    times = 0:1:(datenum(controlVars.climoPeriodEnd)-datenum(controlVars.climoPeriodStart));
    dates = datevec(datenum(controlVars.climoPeriodStart)+times);
    %find dates with same month as generating climatology for
    monthInds = find(dates(:,2) == controlVars.climoMonth);
    size(monthInds)
    controlVars.climoMonth
    dates(1,2)

    %allocate inputStations structure
    inputStations.var = zeros(nSta,length(dates));
    inputStations.avgVar = zeros(nSta,1);

    %read data
    for i = 1:nSta
        fprintf(1,'Loading: %s\n',char(inputStations.meta{1}(i)));
        %create file name string
        fname = sprintf('%s/%s.nc',controlVars.stationDataPath,char(inputStations.meta{1}(i)));

        %read time units
        refTimeStr = ncreadatt(fname,'time','units');
        %create string tokens from units string
        refTimeStr = strsplit(refTimeStr,' ');
        %combine last two tokens (assuming standard units string) to create date string
        refTimeStr = strcat(refTimeStr{3}, {' '}, refTimeStr{4});

        %create date number from date string
        refTime = datenum(refTimeStr);
        %read station time
        staTime = ncread(fname,'time');
        staTime = staTime/86400; %convert from seconds to days
        staTime = datenum(refTime)+staTime;
        
        %find when station time equals first valid averaging day
        startInd = find(staTime == datenum(dates(1,:)));

        %read station data from averaging period
        if(strcmpi(controlVars.variableEstimated,'precip'))
            inputStations.var(i,:) = ncread(fname,'prcp',startInd,length(dates));
        else
            inputStations.var(i,:) = ncread(fname,controlVars.variableEstimated,startInd,length(dates));
        end
        %create average value for days in month in averaging period (e.g. January from 1980-2013)
        inputStations.avgVar(i) = nanmean(inputStations.var(i,monthInds))*monthDays(climoMonth);
    end

end
