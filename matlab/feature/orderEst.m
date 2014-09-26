function [sorder, seg] = orderEst(seg)

% MEAN_THRES = 0.005;
% STD_THRES = 0.05;
% SUM_THRES = 0.5;
% NORM_THRES = 0.1;
dNORM_THRES = 0.1;
% cluster the contour segments
numSeg = length(seg);
norm_seg = zeros(1, numSeg);
% abs_mean_seg = zeros(1, numSeg);
% std_seg = zeros(1, numSeg);
% abs_sum_seg = zeros(1, numSeg);

sorder = zeros(1, numSeg);
od = zeros(1, numSeg);

nL = 1;
line_id = [];         % the index of straight lines

for i = 1:numSeg
    % denoise feature
    [X_tmp,~,~,od(i)] = fast_incremental_hstln_mo(seg{i}',0.01);
    seg{i} = X_tmp';
    
    % detect straight lines
    % 1 for synthetic, 0.8 for 296059 and 241004
%     abs_mean_seg(i) = abs(mean(seg{i}));
%     std_seg(i) = std(seg{i});
%     abs_sum_seg(i) = abs(sum(seg{i}));
    norm_seg(i) = norm(seg{i}, 2);
%     if od(i) == 1
%     if  norm_scA(i) < NORM_THRES
    if norm_seg(i) < dNORM_THRES
%     if abs_mean_dscA(i) < MEAN_THRES && std_dscA(i) < STD_THRES
        %     if abs_sum_dscA(i) < SUM_THRES && norm_dscA(i) < NORM_THRES
        line_id(nL) = i;
        nL = nL + 1;
    end
    
%     sorder(i) = getOrder(sH{i}, 0.95);
    sorder(i) = od(i);
end

% set the order of lines zero
sorder(line_id) = 0;

end