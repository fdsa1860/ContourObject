function index = detectLine(dsca)
% Input:
% seg: 1 by N cell array, each cell contains a L by 2 matrix, which is the
% derivatives of a contour segment's cumulative angle
% Output:
% index: the indices of the line segments

dNORM_THRES = 0.1;

numSeg = length(dsca);
norm_seg = zeros(1, numSeg);
index = false(1, numSeg);

for i = 1:numSeg
    norm_seg(i) = norm(dsca{i}, 2);
    if norm_seg(i) < dNORM_THRES
        index(i) = true;
    end
end