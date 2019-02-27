function aspects = calcTopoAspects(grid,parameters)
%
%% calcTopoAspects computes the cardinal slope facets and flat areas from 
%  a smoothed DEM that is computed internally here. Generally follows Daly
%  et al. (1994)
%
% Author:  Andrew Newman, NCAR/RAL
% Email :  anewman@ucar.edu
%
% Arguments:
%
% Input:
%
%  grid,       structure, the raw grid structure
%  parameters, structure, structrure holding preprocessing parameters
%
% Output:
% 
%  aspects, structure, structure containing smoothed DEM, topographic
%                      facets, and smoothed topographic gradient arrays
%
%

    %print status
    fprintf(1,'Computing topographic aspects\n');

    %define local variable for aspects
    intAspect = zeros(size(grid.dem))-999.0;

    %local variable for minimum gradient
    minGradient = parameters.minGradient;

    %local variable for number of aspects
    nAspects = 5;

    %local variable for minimum size of facets
    nSmallFacet = parameters.smallFacet/(grid.dx^2);  %set size of smallest sloped facet to grid cells
    nSmallFlat = parameters.smallFlat/(grid.dx^2);    %set size of smallest flat facet to grid cells

    %check filter type and set filter
    if(strcmpi(parameters.demFilterName,'daly'))
        demFilter = [0 0.125 0; 0.125 0.5 0.125; 0 0.125 0];
    else
        error('Unknown Filter type %s\n', char(parameters.demFilterName));
    end

    %set local dem variable
    smoothElev = grid.dem;
    smoothElev(isnan(smoothElev)) = 0;

    %filter DEM using demFilterPasses
    for i = 1:parameters.demFilterPasses
        smoothElev = imfilter(smoothElev,demFilter,'replicate');
    end

    %compute the gradients, slope, aspect from the DEM
    [aspect,~,gradNorth,gradEast] = gradientm(grid.lat',grid.lon',smoothElev');

    %transpose aspect, gradients
    aspect = aspect';
    gradNorth = gradNorth';
    gradEast = gradEast';

    %define flat aspects
    flat = abs(gradNorth)<minGradient & abs(gradEast)<minGradient;

    %define cardinal direction aspects
    north = aspect>315 | aspect <=45;
    east = aspect>45 & aspect<=135;
    south = aspect>135 & aspect<=225;
    west = aspect>225 & aspect <= 315;

    intAspect(north) = 1;
    intAspect(east) = 2;
    intAspect(south) = 3;
    intAspect(west) = 4;
    intAspect(flat) = 5;

    %character array of aspects
    for i = 1:max(intAspect)
        switch i
            case 1
                charAspects{i} = 'North';
            case 2
                charAspects{i} = 'East';
            case 3
                charAspects{i} = 'South';
            case 4
                charAspects{i} = 'West';
            case 5
                charAspects{i} = 'Flat';
            otherwise
                error('Unknown aspect');
        end
    end

    %merge small facets
    %find all objects for each aspect and merge small ones into nearby larger
    %aspects using 4- (flat) or 8-connectivity (slopes)
    for i = 1:nAspects
        fprintf(1,'Merging aspect %s\n',char(charAspects{i}));
        if(i < nAspects)
            connectivity = 8;
        else
            connectivity = 4;
        end
        binary = intAspect;
        binary(binary~=i) = 0;
        binary(binary==i) = 1;

        imageObjects = bwlabel(binary,connectivity);
        stats{i} = regionprops(imageObjects,'Area','BoundingBox','MinorAxisLength','MajorAxisLength');

        %merge all small objects into non-flat slopes
        %need to have at least nSmall grid cells to make an actual facet
        %merge into the first facet that is not flat starting west, then south,
        %then east, then north
        if(i < nAspects)
            minSize = nSmallFacet;
        else %flats need to be larger as small flats may behave like nearby slopes
            minSize = nSmallFlat;
        end
        %number of objects for current facet
        nobj = length(stats{i});
        for n = 1:nobj
            %if the current object is too small
            if(stats{i}(n).Area < minSize)
                %find the west and south side bounding points
                westPoints =  [round(stats{i}(n).BoundingBox(1)) round(stats{i}(n).BoundingBox(1)+stats{i}(n).BoundingBox(3))];
                southPoints = [round(stats{i}(n).BoundingBox(2)) round(stats{i}(n).BoundingBox(2)+stats{i}(n).BoundingBox(4))];


                %if the bounding point is outside the grid size, set to grid max
                %dimensions for columns and rows
                if(max(westPoints)>grid.nc)
                    westPoints(2) = grid.nc;
                end
                if(max(southPoints)>grid.nr)
                    southPoints(2) = grid.nr;
                end

                %define north and east bounding points
                northPoints = southPoints;
                eastPoints = westPoints;


                %find the grid cells along the four bounding lines
                westPixels = intAspect(round(stats{i}(n).BoundingBox(2)),westPoints(1):westPoints(2) );
                southPixels = intAspect(southPoints(1):southPoints(2),round(stats{i}(n).BoundingBox(1)));
                %north and east bounding points are defined by the opposite of the 
                %west and south bounding points
                eastPixels = intAspect(southPoints(2),eastPoints(1):eastPoints(2));
                northPixels = intAspect(northPoints(1):northPoints(2),westPoints(2));

                %find the mode of the facets on the bounding lines
                modeWest = mode(westPixels);
                modeEast = mode(eastPixels);
                modeSouth = mode(southPixels);
                modeNorth = mode(northPixels);

                %find the grid cells of the current facet object
                inds = find(imageObjects==n);

                %merge current object into appropriate facet based on bounding
                %line most common facet
                if(modeWest ~= 5 && modeWest ~= i)
                    intAspect(inds) = modeWest; %merge into west-facing slope
                elseif(modeSouth ~=5 && modeSouth ~= i )
                    intAspect(inds) = modeSouth; %merge into south-facing slope
                elseif(modeEast ~=5 && modeEast ~= i)
                    intAspect(inds) = modeEast; %merge into east-facing slope
                elseif(modeNorth ~=5 && modeNorth ~= i)
                    intAspect(inds) = modeNorth; %merge into north-facing slope
                else  %if object cannot merge into slope, default merge into flat
                    intAspect(inds) = 5; %merge into flat area
                end  

            end %end object size if-statement
        end %end object loop
    end %end facet loop


    % merge narrow flat areas that are a likely ridge
    % assume these behave like nearby slopes
    % merge into slopes on the south and west sides only
    fprintf(1,'Merging narrow flats\n');

    %create a binary image of only flat pixels
    i = 5;
    binary = intAspect;
    binary(binary~=i) = 0;
    binary(binary==i) = 1;
    %identify connected pixels
    imageObjects = bwlabel(binary,connectivity);
    %generate statistics about all object features
    flats = regionprops(imageObjects,'Area','BoundingBox','MinorAxisLength','MajorAxisLength','Orientation');

    %loop through all flat objects
    for i = 1:length(flats)
        %if they are very narrow
        if(flats(i).MajorAxisLength/flats(i).MinorAxisLength > parameters.narrowFlatRatio)
            %find the west and south side bounding points
            westPoints =  [floor(flats(i).BoundingBox(1)) floor(flats(i).BoundingBox(1)+flats(i).BoundingBox(3))];
            southPoints = [floor(flats(i).BoundingBox(2)) floor(flats(i).BoundingBox(2)+flats(i).BoundingBox(4))];

    %        round(flats(i).BoundingBox(1))
    %        size(intAspect)
    %        flats(i).BoundingBox

            %find what facets the bounding line grid cells belong to
            westPixels = intAspect(round(flats(i).BoundingBox(2)),westPoints(1):westPoints(2) );
            southPixels = intAspect(southPoints(1):southPoints(2),round(flats(i).BoundingBox(1)));

            %find the mode of the facets on the west and south sides
            modeWest = mode(westPixels);
            modeSouth = mode(southPixels);

            %find current object grid points
            inds = find(imageObjects==i);

            %merge if the mode of the south pixels is not flat and if the
            %current flat is oriented less than 45 degrees
            if(abs(flats(i).Orientation)<=45 && modeSouth ~= 5)
                %merge into South slope
                intAspect(inds) = modeSouth;
            else  %else merge into whatever is along the west bounding box
                %merge into West slope
                intAspect(inds) = modeWest;
            end

        end %end ratio if-statement
    end %end flat loop

    %set smoothElev non-land pixels to missing
    smoothElev(grid.mask<=0) = -999;
    gradNorth(grid.mask<=0) = -999;
    gradEast(grid.mask<=0) = -999;

    intAspect(grid.mask<=0) = -999;

    %define output varibles
    aspects.smoothDEM = smoothElev;
    aspects.gradNorth = gradNorth;
    aspects.gradEast = gradEast;
    aspects.aspects = intAspect;


end %end function