function sigma_all = sigmaEstAll(H_all, isLine_all, verbose)
% Input:
% H_all: 1 by N cell array, each cell contains several hankel matrix
% verbose: enable display process if true
% Output:
% sigma_all: 1 by N cell array, each cell contains a D by K matrix

if nargin < 3
    verbose = false;
end

if nargin < 2 || isempty(isLine_all)
    isLine_all = cell(1, length(H_all));
end

if verbose
    fprintf('computing sigma ...');
end

numImg = length(H_all);
sigma_all = cell(1, numImg);
for i = 1:numImg
    if isempty(H_all{i})
        continue;
    end
    sigma_all{i} = sigmaEst(H_all{i}, isLine_all{i});
end

if verbose
    fprintf('finished!\n');
end

end