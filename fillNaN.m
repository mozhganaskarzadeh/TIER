function filled = fillNaN(inputMatrix,x2d,y2d)
%
%%
%
%
%
    %determine size of matrix
    [nr,nc] = size(inputMatrix);

    %find valid points
    valid = ~isnan(inputMatrix);

    %create 1D vectors with only valid points
    inputMatrix1d = inputMatrix(valid);

    %compute a distance matrix
    distMatrix = sqrt((x2d-(nc/2)).^2+(y2d-(nr/2)).^2);

    %predefine the output matrix
    filled = inputMatrix;

    %loop through all points
    for i = 1:nr
        for j = 1:nc
            %only operate if it is a nan point
            if(isnan(inputMatrix(i,j)))
                %find nearest neighbor
                [~,nnInd] = min(abs(distMatrix(valid)-distMatrix(i,j)));
                %set value to output matrix
                filled(i,j) = inputMatrix1d(nnInd);
             end
         end
     end


end