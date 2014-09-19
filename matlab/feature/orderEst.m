function [dscA, sorder, sH, sHHp] = orderEst(dscA, hankel_size)

MEAN_THRES = 0.005;
STD_THRES = 0.05;
SUM_THRES = 0.5;
NORM_THRES = 0.1;
dNORM_THRES = 0.1;
% cluster the contour segments
numSeg = length(dscA);
norm_dscA = zeros(1, numSeg);
abs_mean_dscA = zeros(1, numSeg);
std_dscA = zeros(1, numSeg);
abs_sum_dscA = zeros(1, numSeg);

sH = cell(1, numSeg);
sHHp = cell(1, numSeg);
sorder = zeros(1, numSeg);
od = zeros(1, numSeg);

nL = 1;
line_id = [];         % the index of straight lines

for i = 1:numSeg
    % denoise feature
    [dscA_tmp,~,~,od(i)] = fast_incremental_hstln_mo(dscA{i}',0.01);
    dscA{i} = dscA_tmp';
    
    % detect straight lines
    % 1 for synthetic, 0.8 for 296059 and 241004
    abs_mean_dscA(i) = abs(mean(dscA{i}));
    std_dscA(i) = std(dscA{i});
    abs_sum_dscA(i) = abs(sum(dscA{i}));
    norm_dscA(i) = norm(dscA{i}, 2);
%     if od(i) == 1
%     if  norm_scA(i) < NORM_THRES
    if norm_dscA(i) < dNORM_THRES
%     if abs_mean_dscA(i) < MEAN_THRES && std_dscA(i) < STD_THRES
        %     if abs_sum_dscA(i) < SUM_THRES && norm_dscA(i) < NORM_THRES
        line_id(nL) = i;
        nL = nL + 1;
    end
    
    [sH{i}, sHHp{i}] = buildHankel(dscA{i}, hankel_size, 1);

%     sorder(i) = getOrder(sH{i}, 0.95);
    sorder(i) = od(i);
end

% set the order of lines zero
sorder(line_id) = 0;

end