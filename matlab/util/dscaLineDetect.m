function index = dscaLineDetect(dsca)
% Input:
% seg: 1 by N cell array, each cell contains a L by 2 matrix, which is the
% derivatives of a contour segment's cumulative angle
% Output:
% index: the indices of the line segments

dNORM_THRES = 0.1;
% MEAN_THRES = 0.005;
% STD_THRES = 0.05;
% SUM_THRES = 0.5;
% NORM_THRES = 0.1;

numSeg = length(dsca);
norm_seg = zeros(1, numSeg);
% abs_mean_seg = zeros(1, numSeg);
% std_seg = zeros(1, numSeg);
% abs_sum_seg = zeros(1, numSeg);
index = false(1, numSeg);

for i = 1:numSeg
%     abs_mean_seg(i) = abs(mean(seg{i}));
%     std_seg(i) = std(seg{i});
%     abs_sum_seg(i) = abs(sum(seg{i}));
    norm_seg(i) = norm(dsca{i}, 2);
%     if abs_mean_dscA(i) < MEAN_THRES && std_dscA(i) < STD_THRES
%     if abs_sum_dscA(i) < SUM_THRES && norm_dscA(i) < NORM_THRES
%     if  norm_scA(i) < NORM_THRES
    if norm_seg(i) < dNORM_THRES
        index(i) = true;
    end
end