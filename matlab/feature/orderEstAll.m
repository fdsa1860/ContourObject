function [X_all_order, X_all_clean] = orderEstAll(X_all, verbose)
% Input:
% X_all: 1 by n cell array, each cell contains several contours from one
% image
% Output:
% X_all_order: 1 by n cell array, each cell contains a vector which listed 
% the estimated order of each contour
% X_all_clean: if hstln is used, this output contains the cleaned data

numImg = length(X_all);
X_all_clean = cell(numImg, 1);
X_all_order = cell(numImg, 1);
for i = 1:numImg
    if verbose
        fprintf('Processing image %d ... \n', i);
    end
    [X_all_order{i}, X_all_clean{i}] = orderEst(X_all{i});
end

if verbose
    fprintf('Process finished!\n');
end

end