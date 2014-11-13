function X = addPoints(X, pts)

nX = length(X);
nP = size(pts, 1);
assert(nX == nP);
for i = 1:nX
    X(i).loc = pts(i, :);
end

end