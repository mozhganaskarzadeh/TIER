function metGrid = allocateMetVars(nr,nc)
%
%% allocateMetVars allocates memory for met variables
%
%
% Author:  Andrew Newman
%
%
% Arguments:
%
%  Input:
%
%   nr, integer, number of rows in grid
%   nc, integer, number of columns in grid
%
%  Output:
%
%   metGrid, structure, structure housing all grids related to
%                       met field generation
%
%

    %allocate space for grids
    metGrid.rawField        = zeros(nr,nc)*NaN;
    metGrid.intercept       = zeros(nr,nc)*NaN;
    metGrid.slope           = zeros(nr,nc)*NaN;
    metGrid.normSlope       = zeros(nr,nc)*NaN;
    metGrid.symapField      = zeros(nr,nc)*NaN;
    metGrid.symapElev       = zeros(nr,nc)*NaN;
    metGrid.symapUncert     = zeros(nr,nc)*NaN;
    metGrid.slopeUncert     = zeros(nr,nc)*NaN;
    metGrid.normSlopeUncert = zeros(nr,nc)*NaN;
    metGrid.defaultSlope    = zeros(nr,nc)*NaN;
    metGrid.finalSlope      = zeros(nr,nc)*NaN;
    metGrid.intercept       = zeros(nr,nc)*NaN;
    metGrid.finalField      = zeros(nr,nc)*NaN;
    metGrid.totalUncert     = zeros(nr,nc)*NaN;
    metGrid.relUncert       = zeros(nr,nc)*NaN;
    metGrid.validRegress    = zeros(nr,nc)*NaN;

end            
