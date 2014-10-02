function [X1_new, X2_new, centers_new] = slideWindowChopContourAll(X1, X2, winSize, verbose)

if nargin < 4
    verbose = false;
end

if verbose
    fprintf('chopping contour using sliding window ...');
end

numImg = length(X1);
X1_new = cell(1, numImg);
X2_new = cell(1, numImg);
centers_new = cell(1, numImg);
for i = 1:numImg
    if isempty(X1{i}) || isempty(X2{i})
        continue;
    end
    [X1_new{i}, X2_new{i}, centers_new{i}] = slideWindowChopContour(X1{i}, X2{i}, winSize);
end

if verbose
    fprintf('finish!\n');
end

end