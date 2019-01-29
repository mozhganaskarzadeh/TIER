function saveOutput(outputName,metGrid) %#ok<*INUSD>
%
%% saveOutput saves the metGrid structure into a netcdf file
% Author: Andrew Newman NCAR/RAL
% Email : anewman@ucar.edu
%
% Arguments:
%
%  Input:
% 
%   outputName, string   , name of output file
%   metGrid   , structure, structure containing STIR met fields
%
%  Output:
% 
%    None

    %save to mat file
    save(outputName,'metGrid','-v7.3');
    
end