%% create narr temp lapse rates

clear all;

%% paths

dpath = '/d2/anewman/oconus/stir';


layerThick=3000; %Pa layer thickness

%% load narr data

%00 UTC as proxy for Tmax
fname = sprintf('%s/narr_1980_2009_01_00utc_avg.nc',dpath);
tmax = ncread(fname,'TMP_221_SPDY_S113');
sfcPresTmax = ncread(fname,'PRES_221_HYBL_S113');

%get grid
narrLat = cast(ncread(fname,'gridlat_221'),'double');
narrLon = cast(ncread(fname,'gridlon_221'),'double');

%12 UTC as proxy for Tmin 
fname = sprintf('%s/narr_1980_2009_01_12utc_avg.nc',dpath);
tmin = ncread(fname,'TMP_221_SPDY_S113');
sfcPresTmin = ncread(fname,'PRES_221_HYBL_S113');

%get target domain lat/lon
fname = sprintf('%s/testOutputGrid.nc',dpath);
gridLat = ncread(fname,'latitude');
gridLon = ncread(fname,'longitude');
%get target domain 2-layer attribute
gridLayers = ncread(fname,'inversion_layer');

[nr,nc] = size(gridLat);

%% compute 2-layer lapse rates
% two layers is compatible with the 2-layer inversion DEM processing of
% Daly et al. (2002)

%
% 00 UTC (tmax)
%
%layer 1 is the NARR 60-90 mb above ground temp - 0-30 mb temp 
layer1Tmax = tmax(:,:,3)- tmax(:,:,1);
% estimate height of the layers
hgt1 = computeHeight(sfcPresTmax-layerThick/2);
hgt2 = computeHeight(sfcPresTmax-(layerThick*2+layerThick/2));
%compute lapse rate
layer1TmaxLapse = layer1Tmax./(hgt2-hgt1)*1000;  %convert K/m to K/km

%layer 2 is the NARR 150-180 mb above ground temp - 90-120 mb temp
layer2Tmax = tmax(:,:,6)- tmax(:,:,4);
%estimate height of the layers
hgt1 = computeHeight(sfcPresTmax-(layerThick*3+layerThick/2));
hgt2 = computeHeight(sfcPresTmax-(layerThick*5+layerThick/2));
%compute lapse rate
layer2TmaxLapse = layer2Tmax./(hgt2-hgt1)*1000;  %convert K/m to K/km

% set layer2 max lapse rate to zero to be consistent with Daly et al. (2002)
layer2TmaxLapse(layer2TmaxLapse>0) = 0;

%
% 12 UTC (tmin)
%
%layer 1 is the NARR 60-90 mb above ground temp - 0-30 mb temp 
layer1Tmin = tmin(:,:,3)- tmin(:,:,1);
% estimate height of the layers
hgt1 = computeHeight(sfcPresTmin-layerThick/2);
hgt2 = computeHeight(sfcPresTmin-(layerThick*2+layerThick/2));
%compute lapse rate
layer1TminLapse = layer1Tmin./(hgt2-hgt1)*1000;  %convert K/m to K/km

%layer 2 is the NARR 150-180 mb above ground temp - 90-120 mb temp
layer2Tmin = tmin(:,:,6)- tmin(:,:,4);
%estimate height of the layers
hgt1 = computeHeight(sfcPresTmin-(layerThick*3+layerThick/2));
hgt2 = computeHeight(sfcPresTmin-(layerThick*5+layerThick/2));
%compute lapse rate
layer2TminLapse = layer2Tmin./(hgt2-hgt1)*1000;  %convert K/m to K/km

% set layer2 max lapse rate to zero to be consistent with Daly et al. (2002)
layer2TminLapse(layer2TminLapse>0) = 0;

%% regrid to domain

%regrid narr to target grid
layer1TmaxLapseRegrid = griddata(narrLat,narrLon,layer1TmaxLapse,gridLat,gridLon);
layer2TmaxLapseRegrid = griddata(narrLat,narrLon,layer2TmaxLapse,gridLat,gridLon);
layer1TminLapseRegrid = griddata(narrLat,narrLon,layer1TminLapse,gridLat,gridLon);
layer2TminLapseRegrid = griddata(narrLat,narrLon,layer2TminLapse,gridLat,gridLon);

%merge layers into one default lapse grid
%where DEM indicates grid point is in layer 1 or 2, use corresponding NARR
%layer estimate
tmaxLapseRegrid = layer1TmaxLapseRegrid;
tmaxLapseRegrid(gridLayers==2) = layer2TmaxLapseRegrid(gridLayers==2);
tmaxLapseRegrid(isnan(gridLayers)) = -999;

tminLapseRegrid = layer1TminLapseRegrid;
tminLapseRegrid(gridLayers==2) = layer2TminLapseRegrid(gridLayers==2);
tminLapseRegrid(isnan(gridLayers)) = -999;

%% example figures
figure(11);imagesc(layer1TmaxLapseRegrid');colorbar;set(gca,'ydir','normal');title('Tmax Layer 1');
figure(12);imagesc(layer2TmaxLapseRegrid');colorbar;set(gca,'ydir','normal');title('Tmax Layer 2');
figure(13);imagesc(layer1TminLapseRegrid');colorbar;set(gca,'ydir','normal');title('Tmin Layer 1');
figure(14);imagesc(layer2TminLapseRegrid');colorbar;set(gca,'ydir','normal');title('Tmin Layer 2');

%% output to netcdf file

outName = sprintf('%s/NARRTempLapseRates.nc',dpath);

%create file and tmaxLapse
nccreate(outName,'tmaxLapse','Dimensions',{'latitude',nr,'longitude',nc},'Format','classic');
ncwrite(outName,'tmaxLapse',tmaxLapseRegrid);
ncwriteatt(outName,'tmaxLapse','name','Lapse rate Tmax');
ncwriteatt(outName,'tmaxLapse','long_name','Tmax lapse rate for idealized estimate of two layer atmosphere (Daly et al. 2002)');
ncwriteatt(outName,'tmaxLapse','_FillValue',-999.0);
ncwriteatt(outName,'tmaxLapse','units','K/km');

%tminLapse
nccreate(outName,'tminLapse','Dimensions',{'latitude',nr,'longitude',nc},'Format','classic');
ncwrite(outName,'tminLapse',tminLapseRegrid);
ncwriteatt(outName,'tminLapse','name','Lapse rate of Tmin');
ncwriteatt(outName,'tminLapse','long_name','Tmin lapse rate for idealized estimate of two layer atmosphere (Daly et al. 2002)');
ncwriteatt(outName,'tminLapse','_FillValue',-999.0);
ncwriteatt(outName,'tminLapse','units','K/km');
