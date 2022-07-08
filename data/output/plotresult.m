clc
clear all
close all



finalField = ncread('caliOutput_prcp_13sta.nc', 'finalField');
totalUncert = ncread('caliOutput_prcp_13sta.nc', 'totalUncert');
relUncert = ncread('caliOutput_prcp_13sta.nc', 'relUncert');
% symapUncert = ncread('caliOutput_prcp_13sta.nc', 'symapUncert');
slopeUncert  = ncread('caliOutput_prcp_13sta.nc', 'slopeUncert');
