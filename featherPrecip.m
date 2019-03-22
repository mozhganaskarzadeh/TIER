function finalPrecip = featherPrecip(parameters,nr,nc,dx,dem,mask,finalNormSlope,symapPrecip,symapElev)
%
%% featherPrecip updates the estimated precipitation field to remove sharp,
%                potentially unrealistic gradients due primarily do to
%                slope aspect processing. Generally follows Daly et al.
%                (1994).  This is the final precipitation processing step.
%
% Author: Andrew Newman NCAR/RAL
% Email : anewman@ucar.edu
%
% Arguments:
%
%  Inputs:
%
%   parameters, structure, stir parameter structure
%   dxy, float, grid spacing (km) of grid
%   dem, float, grid dem
%   mask, integer, mask of valid grid points
%   finalNormslope, float, final normalized slope estimate across grid
%   symapPrecip, float,    symap weighted estimated precipitation 
%   symapElev, float,      elevation of symap weighted stations for symap
%                          estimate
%
%  Outputs:
%
%   finalPrecip, float, grid containing the final precipitation estimate


    %compute precipitation again, using spatially interpolated valid slopes,
    %rather than a mishmash of valid and default values from grid point to
    %grid point
    finalPrecip = finalNormSlope.*symapPrecip.*(dem-symapElev) + symapPrecip;
    finalSlope = finalNormSlope.*symapPrecip;

    %Now check to see if any feathering is needed to relax potentially large grid cell to grid-cell gradients
    %that may be non-physical.  generally follows Daly et al. (1994)
    
    %Here a check of the grid elevation is made to prevent excessive
    %feathering across low and flat elevations.  This may be because of
    %some bug in the algorithm, or some other unknown issue.  This check
    %does not appear to be in Daly et al. (1994)
    
    %set parameter values from input parameter structure
    bufferSlope = parameters.bufferSlope;  %buffer to add to slope change to make sure gradient falls under max_grad when changed
    maxFinalSlope = parameters.maxFinalSlope;  %max normalized slope (Daly et al. 1994)
    maxGrad = parameters.maxGrad;  %normalized slope per km  %each grid cell is dx apart
    demMaxGrad = maxGrad/dx; %grid relative gradient
    minElevDiff = parameters.minElevDiff; %km
    minElev = parameters.minElev; %km

    %first, set negative and zero pcp to mean value
    negInds = find(finalPrecip<=0);
    if(~isempty(negInds))
        finalPrecip(negInds) = symapPrecip(negInds);
    end

    %second need to make sure all the precipitation slopes are within 
    %reasonable bounds
    inds = find(finalNormSlope>maxFinalSlope);
    %reset values to valid final maximum slope
    finalSlope(inds) = maxFinalSlope*symapPrecip(inds);

    %recompute precipitation field using updated slopes
    for i = 1:length(inds)
        finalPrecip(inds(i)) = polyval([finalSlope(inds(i)) symapPrecip(inds(i))],dem(inds(i))-symapElev(inds(i)));
    end

    %now check spatial gradients for exceedance
    %recompute normalized slopes in a temporary variable
    tmpNormSlope = finalSlope./symapPrecip;
    %temporary precipitation variable
    tmpPrecip = finalPrecip;
    tmpNormSlope(mask<0)=NaN;

    %keep track of passes and number of grid points modified
    pass = 1;
    numgridModified = 1;
    while numgridModified > 0
        numgridModified = 0;
        %loop across grid
        for y = 2:nr-1
            if(mod(y,100)==0)
                fprintf(1,'Done with pass %d, row: %d\n',pass,y);
            end
            for x = 2:nc-1
                
                %compute gradients using trailing pt (backward finite
                %difference)
                
                %two step process: East-West graident first
                ewGrad = tmpNormSlope(y,x)-tmpNormSlope(y-1,x);

                %if the gradient exceeds the allowable gradient
                %and the elevation is above minimum and the difference
                %across grid cell elevations is large enough
                %then feather grid point
                if(abs(ewGrad) > demMaxGrad && (abs(dem(y,x)- dem(y-1,x))>minElevDiff || dem(y,x)>minElev))
                    %define static fields
                    tmpIntercept = [symapPrecip(y,x), symapPrecip(y-1,x)];
                    tmpElev = [symapElev(y,x), symapElev(y-1,x)];
                    tmpDem = [dem(y,x), dem(y-1,x)];

                    %define fields that will be updated
                    tmpPrecipArray = [tmpPrecip(y,x), tmpPrecip(y-1,x)];
                    tmpSlopeArray = [tmpNormSlope(y,x), tmpNormSlope(y-1,x)];


                    %which point has smaller precipitation
                    [~,lowInd] = min(tmpPrecipArray);

                    %if the slope of the lower precipitation estimate is valid
                    if(tmpSlopeArray(lowInd)>=maxFinalSlope)
                        %find the index of the minimum slope point
                        [~,lowInd] = min(tmpSlopeArray);
                        
                        %feather (smooth) the slope gradient using the
                        %valid slope
                        tmpPtSlope = ((abs(ewGrad)-demMaxGrad)+bufferSlope+tmpSlopeArray(lowInd));
                        %recompute precipitation with smoothed slope
                        tmpPtPrecip = polyval([tmpPtSlope*tmpIntercept(lowInd) tmpIntercept(lowInd)],tmpDem(lowInd)-tmpElev(lowInd));

                        %update the precipitation and slope values
                        tmpPrecip(y-lowInd+1,x) = tmpPtPrecip;
                        tmpNormSlope(y-lowInd+1,x) = tmpPtSlope;
                    else
                        %if the slope of the lower precipitation estimate is not valid
                        %feather the gradient using lower precipitation
                        %grid point slope.  
                        %this will eventually smooth gradients out
                        %across enough grid points given enough passes
                        tmpPtSlope = ((abs(ewGrad)-demMaxGrad)+bufferSlope+tmpSlopeArray(lowInd));
                        tmpPtPrecip = polyval([tmpPtSlope*tmpIntercept(lowInd) tmpIntercept(lowInd)],tmpDem(lowInd)-tmpElev(lowInd));

                        %update precipitation and slope values
                        tmpPrecip(y-lowInd+1,x) = tmpPtPrecip;
                        tmpNormSlope(y-lowInd+1,x) = tmpPtSlope;
                  %      final_slp_act(y-low_ind+1,x)
                    end      
                   %  if(y==623 && x==652)
                   %     [1 ew_grad final_pcp(y-low_ind+1,x) final_slp_act(y-low_ind+1,x) ]
                   % end
                    %increment counter tracking number of point
                    %modifications
                    numgridModified = numgridModified + 1;
                %    final_pcp(y,x)

                end
                
                %North-South second using updated precipitation and slope 
                %if the East-West gradient feathering changed things
                %compute North-South gradient
                nsGrad = tmpNormSlope(y,x)-tmpNormSlope(y,x-1);


                %if the gradient exceeds the allowable gradient
                %and the elevation is above minimum and the difference
                %across grid cell elevations is large enough
                %then feather grid point
                if(abs(nsGrad) > demMaxGrad && (abs(dem(y,x)- dem(y,x-1))>minElevDiff || dem(y,x) > minElev))
                    %set static fields
                    tmpIntercept = [symapPrecip(y,x), symapPrecip(y,x-1)];
                    tmpElev      = [symapElev(y,x), symapElev(y,x-1)];
                    tmpDem       = [dem(y,x), dem(y,x-1)];

                    %set updated fields
                    tmpPrecipArray = [tmpPrecip(y,x), tmpPrecip(y,x-1)];
                    tmpSlopeArray = [tmpNormSlope(y,x), tmpNormSlope(y,x-1)];

                    %which point is lower precipitation
                    [~,lowInd] = min(tmpPrecipArray);

                    %if the slope of the lower precipitation estimate is valid
                    if(tmpSlopeArray(lowInd)>=maxFinalSlope)
                        %find the index of the minimum slope point
                        [~,lowInd] = min(tmpSlopeArray);
                        %feather (smooth) the slope gradient using the
                        %valid slope
                        tmpPtSlope = ((abs(nsGrad)-demMaxGrad)+bufferSlope+tmpSlopeArray(lowInd));
                        tmpPtPrecip = polyval([tmpPtSlope*tmpIntercept(lowInd) tmpIntercept(lowInd)],tmpDem(lowInd)-tmpElev(lowInd));
                        %recompute precipitation with smoothed slope
                        tmpPrecip(y,x-lowInd+1) = tmpPtPrecip;
                        tmpNormSlope(y,x-lowInd+1) = tmpPtSlope;
                    else
                        %if the slope of the lower precipitation estimate is not valid
                        %feather the gradient using lower precipitation
                        %grid point slope.  
                        %this will eventually smooth gradients out
                        %across enough grid points given enough passes
                        tmpPtSlope = ((abs(nsGrad)-demMaxGrad)+bufferSlope+tmpSlopeArray(lowInd));
                        tmpPtPrecip = polyval([tmpPtSlope*tmpIntercept(lowInd) tmpIntercept(lowInd)],tmpDem(lowInd)-tmpElev(lowInd));

                        %update precipitation and slope values
                        tmpPrecip(y,x-lowInd+1) = tmpPtPrecip;
                        tmpNormSlope(y,x-lowInd+1) = tmpPtSlope;
                    end
                    %increment counter tracking number of point
                    %modifications
                    numgridModified = numgridModified + 1;

                end %gradient check

            end %x
        end %y
        %increment pass counter
        pass = pass + 1;
        fprintf(1,'%d points modified\n',numgridModified);
    end  %passes


    %finally recheck any negative and zero pcp to mean value
    negInds = find(tmpPrecip<=0);
    if(~isempty(negInds))
        tmpPrecip(negInds) = symapPrecip(negInds);
    end
    %set final precipitation
    finalPrecip = tmpPrecip;
    %invalid grid points set to missing
    finalPrecip(mask<0) = -999;
    
end