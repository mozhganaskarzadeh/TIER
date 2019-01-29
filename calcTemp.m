function metPoint = calcTemp(parameters,gridElev,gridLayer,finalWeights,finalWeightsAspect,symapWeights,stationElevNear,stationElevAspect,stationVarNear,stationVarAspect)
%
%% calcTemp computes the first pass STIR estimate of varEstimated
%
% Summary: This algorithm generally follows Daly et al. (1994,2002,2007,2008) and
% others.  However, here the regression estimated parameters
% and the grid point elevation to compute the precipitation is not done.
% Instead, the SYMAP estimate is used at all grid points as the intercept
% and the weighted linear regression slope is used to adjust the SYMAP
% estimate up or down based on the elevation difference between the grid
% and the SYMAP weighted station elevation.  This approach gives similar
% results and is effectively an elevation adjustment to a SYMAP estimate
% where the SYMAP weights here are computed using all knowledge based
% terms in addition to the SYMAP distance & angular isolation weights
% Other modifications from the above cited papers are present and
% summarized below.
   

% Specific modifications/notes for initial temperature implementation 
% (eq. 2, Daly et al. 2002):
% 1) Here there are only 4-directional facets and flat (see stirPreprocessing.m for details)
%    1 = N
%    2 = E
%    3 = S
%    4 = W
%    5 = Flat
% 2) no elevation weighting factor
% 3) cluster weighting factor using symap type weighting
% 4) no topographic facet weighting factor

% 5) number of stations and facet weighting:
% the nMaxNear nearest stations are always used to determine the base
% temperature value, then only stations on the correct facet are
% used to determine the elevation-variable relationship (slope).  
% facet weighting where stations on same facet but with other facets 
% inbetween get less weight is not considered.  All stations on the same 
% facet get the same "facet" weight
% 6) default lapse rates can be determined from available sounding data that
% has been interpolated to the DEM
% 7) used a search radius of 20-km for layer-1 or 2 determination for temp
% inversions (see stirPreprocessing.m for details)
% 8) The coastal proximity weighting of Daly et al. (2003) is not
% implemented
% 9) default lapse rates are updated after first pass to remove the
% spatially constant default lapse rate constraint (updateTempSlope.m)
%
% Author: Andrew Newman NCAR/RAL
% Email : anewman@ucar.edu
%
% Arguments:
%
%  Input:
%
%   parameters  , structure, structure holding all STIR parameters
%   gridElev    , float    , elevation of current grid point
%   gridLayer   , float    , grid point layer in conceptual two-layer
%                            atmosphere (Daly et al. 2002)
%   defaultSlope, float    , default normalized precipitation slope at
%                            current grid point as current grid point
%   finalWeights,       float, station weights for nearby stations
%   finalWeightsAspect, float, station weights for nearby stations on same
%                              slope aspect
%   symapWeights,      float , symap station weights for nearby stations
%   stationElevNear,   float , station elevations for nearby stations
%   stationElevAspect, float , station elevations for nearby stations on
%                              same slope aspect as current grid point
%   stationVarNear   , float , station values for nearby stations
%   stationVarAspect , float , sataion values for nearby stations on same 
%                              slope aspect as current grid point
%
%  Output:
%
%   metPoint, structure, structure housing all grids related to
%                        precipitation for the current grid point
%
%
    %set local min station parameter
    nMinNear = parameters.nMinNear;
    
    %local slope values
    minSlope = parameters.minSlope;
    maxSlopeLower = parameters.maxSlopeLower;
    maxSlopeUpper = parameters.maxSlopeUpper;

    
    %initalize metPoint structure
    metPoint.rawField        = NaN;
    metPoint.intercept       = NaN;
    metPoint.slope           = NaN;
    metPoint.symapField      = NaN;
    metPoint.symapElev       = NaN;
    metPoint.symapUncert     = NaN;
    metPoint.slopeUncert     = NaN;
    metPoint.intercept       = NaN;
    metPoint.validRegress    = NaN;
    
    %first estimate the 'SYMAP' value at grid point, but use full knowledge
    %based weights if possible. this serves as the base estimate with no 
    %weighted linear elevation regression

    %if the final weight vector is invalid, default to symap weights only
    if(isnan(finalWeights(1)))
        %compute SYMAP precipitaiton
        metPoint.symapField = sum(symapWeights.*stationVarNear)/sum(symapWeights);
        %compute mean elevation of SYMAP stations
        metPoint.symapElev = sum(symapWeights.*stationElevNear)/sum(symapWeights);
        %uncertainty
        nsta = length(symapWeights);
        combs = nchoosek(1:nsta,nsta-1);
        metPoint.symapUncert = std(sum(symapWeights(combs).*stationVarNear(combs),2)./sum(symapWeights(combs),2));
    else %estimate simple average using final weights
        metPoint.symapField = sum(finalWeights.*stationVarNear)/sum(finalWeights);
        metPoint.symapElev = sum(finalWeights.*stationElevNear)/sum(finalWeights);
        %uncertainty
        nsta = length(symapWeights);
        combs = nchoosek(1:nsta,nsta-1);
        metPoint.symapUncert = std(sum(finalWeights(combs).*stationVarNear(combs),2)./sum(finalWeights(combs),2));
    end


    %if there are more than nMinNear stations, proceed with
    %weighted elevation regression
    if(length(stationElevAspect) >= nMinNear)
        %create weighted linear regression relationship
        linFit = calcWeightedRegression(stationElevAspect,stationVarAspect,finalWeightsAspect);
  

        %Run through station combinations and find outliers to see if we
        %can get a valid met var - elevation slope
        %make comparisons for valid slope 
        %temperature has bounds for each layer
        elevSlope = linFit(1);
        if(elevSlope < minSlope || (elevSlope > maxSlopeLower && gridLayer==1) || (elevSlope>maxSlopeUpper && gridLayer==2))

            nSta = length(stationVarAspect);
            maxSlopeDelta = 0;

            for i = nSta-1
                combs = nchoosek(1:nSta,i);
                cnt = 1;
                combSlp = zeros(1,1);
                for c = 1:length(combs(:,1))
                    X = [ones(size(stationElevAspect(combs(c,:)))) stationElevAspect(combs(c,:))];

                    %if X is square
                    if(size(X,1)==size(X,2))
                        %if X is well conditioned
                        if(rcond(X)>tiny)
                            tmpLinFit = calcWeightedRegression(stationElevAspect(combs(c,:)),stationVarAspect(combs(c,:)),...
                                                               finalWeightsAspect(combs(c,:)));
                            elevSlopeTest = tmpLinFit(1);
                            slopeDelta = abs(elevSlope - elevSlopeTest);
                        else %if X not well conditioned, set to unrealistic values
                            elevSlopeTest = large;
                            slopeDelta = -large;
                        end
                    else
                        tmpLinFit = calcWeightedRegression(stationElevAspect(combs(c,:)),stationVarAspect(combs(c,:)),...
                                                               finalWeightsAspect(combs(c,:)));
                        elevSlopeTest = tmpLinFit(1);
                        slopeDelta = abs(elevSlope - elevSlopeTest);
                    end

                    if(elevSlopeTest > minSlope && slopeDelta > maxSlopeDelta)
                        if((elevSlopeTest < maxSlopeLower && gridLayer == 1) || (elevSlopeTest < maxSlopeUpper && gridLayer == 2))
                            removeOutlierInds = combs(c,:);
                            maxSlopeDelta = slopeDelta;
                            combSlp(cnt) = elevSlopeTest;
                            cnt = cnt + 1;
                        end
                    elseif(elevSlopeTest > minSlope)
                        if((elevSlopeTest < maxSlopeLower && gridLayer == 1) || (elevSlopeTest < maxSlopeUpper && gridLayer == 2))
                            combSlp(cnt) = elevSlopeTest;
                            cnt = cnt + 1;
                        end
                    end
                end %end of combination loop
                
                %if two or more valid combination of stations
                %estimate uncertainty of slope at grid point using standard
                %deviation of estimates
                if(cnt > 2)
                    metPoint.SlopeUncert = std(combSlp);
                end
            end
            
            if(maxSlopeDelta>0)
                linFit = calcWeightedRegression(stationElevAspect(removeOutlierInds),stationVarAspect(removeOutlierInds),...
                                                finalWeightsAspect(removeOutlierInds));
                                            
                linFit(2) = metPoint.symapField;
                
                if(isnan(linFit(1)))
                    linFit(1) = defaultSlope;
                    tmpField = polyval(linFit,gridElev-metPoint.symapElev);
                else
                    tmpField = polyval(linFit,gridElev-metPoint.symapElev);
                end
                metPoint.rawField = tmpField;
                metPoint.slope = linFit(1);
                metPoint.intercept = linFit(2);
                metPoint.validRegress = 1;
                
            else
                linFit(1) = defaultSlope;
                linFit(2) = metPoint.symapField;
                
                metPoint.rawField = polyval(linFit,gridElev-metPoint.symapElev);
                metPoint.slope      = linFit(1);
                metPoint.intercept  = linFit(2);
            end

        elseif(isnan(linFit(1)))
            linFit(1) = defaultSlope*metPoint.symapField;
            linFit(2) = metPoint.symapField;
            
            metPoint.rawField  = polyval(linFit,gridElev-metPoint.symapElev);
            metPoint.slope     = linFit(1);
            metPoint.intercept = linFit(2);
        else            
            
            linFit(2) = metPoint.symapField;
            
            metPoint.rawField = polyval(linFit,gridElev-metPoint.symapElev);
            metPoint.slope     = linFit(1);
            metPoint.intercept = linFit(2);
            metPoint.validRegress = 1;

            %run through station combinations to estimate uncertainty in
            %slope estimate
            nSta = length(stationVarAspect);
            combs = nchoosek(1:nSta,nSta-1);
            cnt = 1;
            combSlp = zeros(1,1);
            for c = 1:length(combs(:,1))
                X = [ones(size(stationElevAspect(combs(c,:)))) stationElevAspect(combs(c,:))];
                
                %if X is square
                if(size(X,1)==size(X,2))
                    %if X is well conditioned
                    if(rcond(X) > tiny)
                        tmpLinFit = calcWeightedRegression(stationElevAspect(combs(c,:)),stationVarAspect(combs(c,:)),...
                                                               finalWeightsAspect(combs(c,:)));
                        elevSlopeTest = tmpLinFit(1);
                    else
                        elevSlopeTest = large;
                    end
                else
                    tmpLinFit = calcWeightedRegression(stationElevAspect(combs(c,:)),stationVarAspect(combs(c,:)),...
                                                               finalWeightsAspect(combs(c,:)));
                    elevSlopeTest = tmpLinFit(1);
                end
                
                if((elevSlopeTest < maxSlopeLower && gridLayer == 1) || (elevSlopeTest < maxSlopeUpper && gridLayer == 2))
                    combSlp(cnt) = elevSlopeTest;
                    cnt = cnt + 1;
                end
            
            end %end of combination loop
            
            %if two or more valid combination of stations
            %estimate uncertainty of slope at grid point using standard
            %deviation of estimates
            if(cnt>2)
                metPoint.SlopeUncert = std(combSlp);
            end
        end 

    else %not enough stations within range on aspect - revert to nearest with default slope
        
        linFit(1) = defaultSlope;
        linFit(2) = metPoint.symapField;
        
        metPoint.rawField = polyval(linFit,gridElev-metPoint.symapElev);
        metPoint.slope     = linFit(1);
        metPoint.intercept = linFit(2);

    end %end enough stations if-statement

end