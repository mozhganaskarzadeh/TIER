function saveOutput(outputName,outputVar,metGrid)
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

    %size of grid
    [nr,nc] = size(metGrid.rawField);
    
    %First save to mat file
    save(outputName,'metGrid','-v7.3');
    
    %units check
    if(strcmpi(outputVar,'precip'))
        physicalUnits = 'mm/day';
        normSlopeUnits = 'km-1';
        slopeUnits = 'mm/km';
    elseif(strcmpi(outputVar,'tmax') || strcmpi(outputVar,'tmin'))
        physicalUnits = 'deg_C';
        slopeUnits = 'deg_C/km';
    end
    
    %Also save to netcdf file
    %create file, set dimensions and write first variable rawField
    nccreate(outputName,'rawField','Dimensions',{'latitude',nr,'longitude',nc},'Format','classic');
    ncwrite(outputName,'rawField',metGrid.rawField);
    ncwriteatt(outputName,'rawField','name','raw variable output');
    ncwriteatt(outputName,'rawField','long_name','Raw variable output before slope and gradient adjustments');
    ncwriteatt(outputName,'rawField','units',physicalUnits);
    ncwriteatt(outputName,'rawField','_FillValue',-999.0);
    
    %intercept
    nccreate(outputName,'intercept','Dimensions',{'latitude',nr,'longitude',nc},'Format','classic');
    ncwrite(outputName,'intercept',metGrid.intercept);
    ncwriteatt(outputName,'intercept','name','intercept parameter');
    ncwriteatt(outputName,'intercept','long_name','Intercept parameter from the variable-elevation regression');
    ncwriteatt(outputName,'intercept','units',physicalUnits);
    ncwriteatt(outputName,'intercept','_FillValue',-999.0);
    
    %slope
    nccreate(outputName,'slope','Dimensions',{'latitude',nr,'longitude',nc},'Format','classic');
    ncwrite(outputName,'slope',metGrid.slope);
    ncwriteatt(outputName,'slope','name','variable elevation slope');
    ncwriteatt(outputName,'slope','long_name','Raw variable elevation slope before slope adjustments');
    ncwriteatt(outputName,'slope','units',slopeUnits);
    ncwriteatt(outputName,'slope','_FillValue',-999.0);
    
    %normalized slope (valid for precipitation only)
    %normSlope
    nccreate(outputName,'normSlope','Dimensions',{'latitude',nr,'longitude',nc},'Format','classic');
    ncwrite(outputName,'normSlope',metGrid.normSlope);
    ncwriteatt(outputName,'normSlope','name','normalized variable slope');
    ncwriteatt(outputName,'normSlope','long_name','normalized variable elevation slope before slope adjustments(valid for precipitation only)');
    ncwriteatt(outputName,'normSlope','units',normSlopeUnits);
    ncwriteatt(outputName,'normSlope','_FillValue',-999.0);
    
    %symapField
    nccreate(outputName,'symapField','Dimensions',{'latitude',nr,'longitude',nc},'Format','classic');
    ncwrite(outputName,'symapField',metGrid.symapField);
    ncwriteatt(outputName,'symapField','name','SYMAP estimate');
    ncwriteatt(outputName,'symapField','long_name','SYMAP estimated variable values on grid');
    ncwriteatt(outputName,'symapField','units',physicalUnits);
    ncwriteatt(outputName,'symapField','_FillValue',-999.0);
    
    %symapElev
    nccreate(outputName,'symapElev','Dimensions',{'latitude',nr,'longitude',nc},'Format','classic');
    ncwrite(outputName,'symapElev',metGrid.symapElev);
    ncwriteatt(outputName,'symapElev','name','SYMAP weighted elevation');
    ncwriteatt(outputName,'symapElev','long_name','Grid point elevation estimate using station elevations and SYMAP weights');
    ncwriteatt(outputName,'symapElev','units','m');
    ncwriteatt(outputName,'symapElev','_FillValue',-999.0);
    
    %symapUncert
    nccreate(outputName,'symapUncert','Dimensions',{'latitude',nr,'longitude',nc},'Format','classic');
    ncwrite(outputName,'symapUncert',metGrid.symapUncert);
    ncwriteatt(outputName,'symapUncert','name','SYMAP uncertainty');
    ncwriteatt(outputName,'symapUncert','long_name','Uncertainty estimate from the SYMAP variable estimate');
    ncwriteatt(outputName,'symapUncert','units',physicalUnits);
    ncwriteatt(outputName,'symapUncert','_FillValue',-999.0);
    
    %slopeUncert
    nccreate(outputName,'slopeUncert','Dimensions',{'latitude',nr,'longitude',nc},'Format','classic');
    ncwrite(outputName,'slopeUncert',metGrid.slopeUncert);
    ncwriteatt(outputName,'slopeUncert','name','slope uncertainty');
    ncwriteatt(outputName,'slopeUncert','long_name','Uncertainty estimate (physical space) resulting from the variable-elevation slope estimate');
    ncwriteatt(outputName,'slopeUncert','units',physicalUnits);
    ncwriteatt(outputName,'slopeUncert','_FillValue',-999.0);
    
    %normSlopeUncert (valid for precipitation only)
    nccreate(outputName,'normSlopeUncert','Dimensions',{'latitude',nr,'longitude',nc},'Format','classic');
    ncwrite(outputName,'normSlopeUncert',metGrid.normSlopeUncert);
    ncwriteatt(outputName,'normSlopeUncert','name','normalized slope uncertainty');
    ncwriteatt(outputName,'normSlopeUncert','long_name','Uncertainty estimate (normalized) resulting from the variable-elevation slope estimate(valid for precipitation only)');
    ncwriteatt(outputName,'normSlopeUncert','units',normSlopeUnits);
    ncwriteatt(outputName,'normSlopeUncert','_FillValue',-999.0);
    
    %defaultSlope
    nccreate(outputName,'defaultSlope','Dimensions',{'latitude',nr,'longitude',nc},'Format','classic');
    ncwrite(outputName,'defaultSlope',metGrid.defaultSlope);
    ncwriteatt(outputName,'defaultSlope','name','default slope');
    ncwriteatt(outputName,'defaultSlope','long_name','default elevation-variable slope estimate');
    ncwriteatt(outputName,'defaultSlope','units',slopeUnits);
    ncwriteatt(outputName,'defaultSlope','_FillValue',-999.0);
    
    %finalSlope
    nccreate(outputName,'finalSlope','Dimensions',{'latitude',nr,'longitude',nc},'Format','classic');
    ncwrite(outputName,'finalSlope',metGrid.finalSlope);
    ncwriteatt(outputName,'finalSlope','name','final slope');
    ncwriteatt(outputName,'finalSlope','long_name','Final variable elevation slope after slope adjustments');
    ncwriteatt(outputName,'finalSlope','units',slopeUnits);
    ncwriteatt(outputName,'finalSlope','_FillValue',-999.0);
    
    %finalField
    nccreate(outputName,'finalField','Dimensions',{'latitude',nr,'longitude',nc},'Format','classic');
    ncwrite(outputName,'finalField',metGrid.finalField);
    ncwriteatt(outputName,'finalField','name','final variable output');
    ncwriteatt(outputName,'finalField','long_name','Final variable output after slope and gradient adjustments');
    ncwriteatt(outputName,'finalField','units',physicalUnits);
    ncwriteatt(outputName,'finalField','_FillValue',-999.0);
    
    %totalUncert
    nccreate(outputName,'totalUncert','Dimensions',{'latitude',nr,'longitude',nc},'Format','classic');
    ncwrite(outputName,'totalUncert',metGrid.totalUncert);
    ncwriteatt(outputName,'totalUncert','name','total uncertainty');
    ncwriteatt(outputName,'totalUncert','long_name','total uncertainty in physical units');
    ncwriteatt(outputName,'totalUncert','units',physicalUnits);
    ncwriteatt(outputName,'totalUncert','_FillValue',-999.0);
    
    %relUncert
    nccreate(outputName,'relUncert','Dimensions',{'latitude',nr,'longitude',nc},'Format','classic');
    ncwrite(outputName,'relUncert',metGrid.relUncert);
    ncwriteatt(outputName,'relUncert','name','relative uncertainty');
    ncwriteatt(outputName,'relUncert','long_name','relative total uncertainty');
    ncwriteatt(outputName,'relUncert','units','-');
    ncwriteatt(outputName,'relUncert','_FillValue',-999.0);
    
    %validRegress
    nccreate(outputName,'validRegress','Dimensions',{'latitude',nr,'longitude',nc},'Format','classic');
    ncwrite(outputName,'validRegress',metGrid.validRegress);
    ncwriteatt(outputName,'validRegress','name','valid regression');
    ncwriteatt(outputName,'validRegress','long_name','flag denoting the elevation-variable regression produced a valid slope');
    ncwriteatt(outputName,'validRegress','units','-');
    ncwriteatt(outputName,'validRegress','_FillValue',-999.0);
    
    
end