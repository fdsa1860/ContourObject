function index_all = dscaLineDetectAll(dsca_all, verbose)
% Input:
% dsca_all: 1 by N cell, N is the number of images, each cell contains all
% the cumulative angle derivative
% verbose: enable showing process
% Output:
% index_all: 1 by N cell, each cell contains binary index indicating
% whether the corresponding segment is a line or not

if nargin < 2
    verbose = false;
end

if verbose
    fprintf('detecting lines ...');
end
    
numImg = length(dsca_all);
index_all = cell(1, numImg);
for i = 1:numImg
    index_all{i} = dscaLineDetect(dsca_all{i});
end

if verbose
    fprintf('finished!\n');
end

end