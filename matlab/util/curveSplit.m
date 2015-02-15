function seg = curveSplit(S, v)
% split contour according to indices
% Input:
% S: n-by-2 matrix, the contour coordinates
% v: n-by-1 vector, indication vector, 1 means keeping, 0 means
% getting rid of
% Output:
% seg: 1-by-k cell array, segments of contours

n = size(S, 1);
assert(length(v)==n);
isClosed = (S(1,1)==S(end,1) && S(1,2)==S(end,2));

% if all points are valid return S
if all(v), seg{1} = S; return; end

% if the contour is not closed, just split it
dv = diff(v);
indS = find(dv==1)+1;
indE = find(dv==-1);
if v(1), indS = [1; indS]; end
if v(end), indE = [indE; n]; end
k = length(indS);
assert(length(indE)==k);
seg = cell(1, k);
for i = 1:k
    seg{i} = S(indS(i):indE(i), :);
end

% if the contour is not closed, just split it
if isClosed && v(1)
    assert(v(1)==v(end));
    tmp = seg{1}(2:end, :);
    seg{k} = [seg{k}; tmp];
    seg(1) = [];
end

end