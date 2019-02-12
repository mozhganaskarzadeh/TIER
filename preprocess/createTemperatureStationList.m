function createTemperatureStationList(controlVars,grid)
%
%%
%
%
%

    %define local variables
    nr = grid.nr;
    nc = grid.nc;

    %find nearest grid point
    %transform grid to 1-d arrays for computational convenience
    lon1d = reshape(grid.lon,[nr*nc 1]);
    lat1d = reshape(grid.lat,[nr*nc 1]);
    aspect1d = reshape(grid.aspects,[nr*nc 1]);
    distToCoast1d = reshape(grid.distToCoast,[nr*nc 1]);
    layerMask1d = reshape(grid.layerMask,[nr*nc 1]);
    topoPosition1d = reshape(grid.topoPosition,[nr*nc 1]);

    %create list of stations in directory
    listString = sprintf('%s.nc',controlVars.stationTempPath);
    fileList = ls(listString);
    %number of stations
    nSta = length(fileList);
    %read lat,lon from station timeseries file
    for f = 1:nSta
        stationName = sprintf('%s/%s.nc',controlVars.stationTempPath,fileList(f).name);
        station.lat(f) = ncread(stationName,'latitude');
        station.lon(f) = ncread(stationName,'longitude');
        station.elev(f) = ncread(stationName,'elevation');
    end

    %open output station list file
    sidOut = fopen(controlVars.stationTempListName,'w');

    %print header to output file
    fprintf(sidOut,'NSITES %d\n',nSta);
    fprintf(sidOut,'#STNID\tLAT\tLON\tELEV\tASP\tDIST_COAST\tINVERSION\tTOPO_POS\tSTN_NAME\n');

    %loop through all stations and find the nearest grid point for geophysical
    %attributes
    for i = 1:nSta
    %for i = 150
        %compute distances and indices of nearest grid points
        [~,ix] = sort(sqrt((lat1d-station.lat(i)).^2 + (lon1d-station.lon(i)).^2));

        %if nearest grid point is valid
        if(~isnan(aspect1d(ix(1))))
            %output geophysical attributes to file
            fprintf(sidOut,'%s, %9.5f, %11.5f, %7.2f, %d, %8.3f, %d, %8.3f, %s\n',char(fileList(i).name),station.lat(i),station.lon(i),...
                             station.elev(i),aspect1d(ix(1)),distToCoast1d(ix(1)),layerMask1d(ix(1)),topoPosition1d(ix(1)),char(fileList(i).name));
        else %if not valid
            %find the nearest valid point for all attributes
            nearestValid = find(~isnan(aspect1d(ix)) == 1);

            fprintf(sidOut,'%s, %9.5f, %11.5f, %7.2f, %d, %8.3f, %d, %8.3f, %s\n',char(fileList(i).name),station.lat(i),station.lon(i),...
                            station.elev(i),aspect1d(ix(nearestValid(1))),distToCoast1d(ix(nearestValid(1))),...
                            layerMask1d(ix(nearestValid(1))),topoPosition1d(ix(nearestValid(1))),char(fileList(i).name));     
        end
    end
    %close output list file
    fclose(sidOut);

end
