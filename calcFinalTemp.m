function finalTemp = calcFinalTemp(dem,mask,symapElev,symapTemp,finalSlope)
%
%% calFinalTemp computes the final temperature grid after all adjustments
%
% Author: Andrew Newman NCAR/RAL
% Email : anewman@ucar.edu
%
% Arguments:
%
%  Inputs:
%
%   dem,  float  , grid dem
%   mask, integer, mask of valid grid points
%
%   symapElev, float, elevation of symap weighted stations for symap
%                     estimate
%   symapTemp, float, symap estimated temperature
%   finaSlope, float, grid of final slope estimates after any previous 
%                     adjustments 
%
%  Outputs:
%
%   finalTemp, structure, structure containing the final temperature
%                         estimate across the grid
%
    %compute final temp using all finalized estimates
    finalTemp = finalSlope.*(dem-symapElev) + symapTemp;
    %set unused grid points to missing
    finalTemp(mask==0) = -999;

end