function X_all = sigmaEstAll(X_all, verbose)
% Input:
% H_all: 1 by N cell array, each cell contains several hankel matrix
% verbose: enable display process if true
% Output:
% sigma_all: 1 by N cell array, each cell contains a D by K matrix

if nargin < 2
    verbose = false;
end

if verbose
    fprintf('computing sigma ...');
end

numImg = length(X_all);
for i = 1:numImg
    if isempty(X_all(i).seg)
        continue;
    end
    X_all(i).seg = sigmaEst(X_all(i).seg);
end

if verbose
    fprintf('finished!\n');
end

end