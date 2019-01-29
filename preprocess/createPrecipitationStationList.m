function createPrecipitationStationList(controlVars,grid)
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
gradNorth1d = reshape(grid.aspects.gradNorth,[nr*nc 1]);
gradEast1d = reshape(grid.aspects.gradEast,[nr*nc 1]);
dem1d = reshape(grid.aspects.smoothDEM,[nr*nc 1]);
aspect1d = reshape(grid.aspects.aspects,[nr*nc 1]);
distToCoast1d = reshape(grid.distToCoast,[nr*nc 1]);
layerMask1d = reshape(grid.positions.layerMask,[nr*nc 1]);
topoPosition1d = reshape(grid.positions.topoPosition,[nr*nc 1]);


%create list of stations in directory

%read metadata from station files
%lat, lon


%open station file
sidOut = fopen(controlVars.stationListName,'w');


%print header to output file
fprintf(sidOut,'NSITES %d\n',length(s_data{1}));
%    fprintf(sid_out,'#STNID\tLAT\tLON\tELEV\tSLP_N\tSLP_E\tASP\tDIST_COAST\tINVERSION\tTOPO_POS\tSTN_NAME\n');
fprintf(sidOut,'#STNID\tLAT\tLON\tELEV\tSLP_N\tSLP_E\tASP\tSTN_NAME\n');

for i = 1:length(s_data{1})
%for i = 150
    [diff_dist,ix] = sort(sqrt((lat1d-s_data{2}(i)).^2 + (lon1d-s_data{3}(i)).^2));
    if(gradNorth1d(ix(1)) ~= -999 && gradEast1d(ix(1)) ~=-999 && aspect1d(ix(1)) ~= -999)
%            fprintf(sid_out,'%s, %9.5f, %11.5f, %7.2f, %8.3f, %8.3f, %s\n',char(s_data{1}(i)),s_data{2}(i),s_data{3}(i),...
%                             s_data{4}(i),smoothed_grad_n_1d(ix(1)),smoothed_grad_e_1d(ix(1)),char(s_data{5}(i)));
        fprintf(sidOut,'%s, %9.5f, %11.5f, %7.2f, %8.3f, %8.3f, %d, %8.3f, %d, %8.3f, %s\n',char(s_data{1}(i)),s_data{2}(i),s_data{3}(i),...
                         dem1d(ix(1)),gradNorth1d(ix(1)),gradEast1d(ix(1)),aspect1d(ix(1)),...
                         distToCoast1d(ix(1)),layerMask1d(ix(1)),topoPosition1d(ix(1)),char(s_data{1}(i)));
%             fprintf(sid_out,'%s, %9.5f, %11.5f, %7.2f, %8.3f, %8.3f, %d, %s\n',char(s_data{1}(i)),s_data{2}(i),s_data{3}(i),...
%                             smooth_dem_1d(ix(1)),smoothed_grad_n_1d(ix(1)),smoothed_grad_e_1d(ix(1)),int_asp_1d(ix(1)),...
%                             char(s_data{1}(i)));
    else
        ll = find(gradNorth1d(ix) ~= -999);
        ll2 = find(gradEast1d(ix) ~= -999);
        ll3 = find(aspect1d(ix) ~= -999);
        ll4 = find(distToCoast1d(ix) ~= -999);
        ll5 = find(layerMask1d(ix) ~= -1);
        ll6 = find(topoPosition1d(ix) ~= -999);

%        fprintf(sid_out,'%s, %9.5f, %11.5f, %7.2f, %8.3f, %8.3f, %s\n',char(s_data{1}(i)),s_data{2}(i),s_data{3}(i),...
%                        s_data{4}(i),smoothed_grad_n_1d(ix(ll(1))),smoothed_grad_e_1d(ix(ll2(1))),char(s_data{5}(i)));
        fprintf(sidOut,'%s, %9.5f, %11.5f, %7.2f, %8.3f, %8.3f, %d, %8.3f, %d, %8.3f, %s\n',char(s_data{1}(i)),s_data{2}(i),s_data{3}(i),...
                        dem1d(ix(ll(1))),gradNorth1d(ix(ll(1))),gradEast1d(ix(ll2(1))),aspect1d(ix(ll3(1))),...
                        distToCoast1d(ix(ll4(1))),layerMask1d(ix(ll5(1))),topoPosition1d(ix(ll6(1))),char(s_data{1}(i)));
%            fprintf(sid_out,'%s, %9.5f, %11.5f, %7.2f, %8.3f, %8.3f, %d, %s\n',char(s_data{1}(i)),s_data{2}(i),s_data{3}(i),...
%                            smooth_dem_1d(ix(ll(1))),smoothed_grad_n_1d(ix(ll(1))),smoothed_grad_e_1d(ix(ll2(1))),int_asp_1d(ix(ll3(1))),...
%                            char(s_data{1}(i)));        
    end
end
fclose(sidOut);

end
