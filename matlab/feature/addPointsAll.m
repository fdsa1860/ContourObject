function X_all = addPointsAll(X_all, pts_all, verbose)

if nargin < 3
    verbose = false;
end

if verbose
    fprintf('adding locs ...');
end

nX = length(X_all);
nP = length(pts_all);
assert(nX==nP);
for i = 1:nX
    X_all{i} = addPoints(X_all{i}, pts_all{i});
end

if verbose
    fprintf('finish!\n');
end

end