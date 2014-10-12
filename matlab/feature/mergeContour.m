function mergedSeg = mergeContour(cont)


eta_thr = 0.3;
maxLen = 15;
LargeNum = 100;
numSeg = length(cont);
label = zeros(numSeg, 1);
D_half = zeros(numSeg);
rr = zeros(numSeg);
crossPt = zeros(numSeg, 2);
seg = cell(numSeg, 1);
r = zeros(numSeg, 1);
% only take the boundary segment of each contour to match
for i = 1:numSeg
    if size(cont{i}, 1) > maxLen
        seg{i} = cont{i}(1:maxLen, :);
    else
        seg{i} = cont{i};
    end
    crossPt(i, :) = seg{i}(1, :);
    [seg_tmp,~,~,r(i)] = fast_incremental_hstln_mo(seg{i}',eta_thr);
end
% construct distance matrix 
for i = 1:numSeg
    for j = i+1:numSeg
        if ~all(crossPt(i, :)==crossPt(j, :))
            D_half(i, j) = LargeNum;
        else
        seg2 = [seg{i}(end:-1:2, :); seg{j}];
        [seg2_tmp,~,~,rr(i, j)] = fast_incremental_hstln_mo(seg2',eta_thr);
        D_half(i, j) =  2 * rr(i, j) - r(i) - r(j);
        end
    end
end
D = D_half + D_half' + LargeNum * eye(numSeg);
% 
k = 1;
for i = 1:numSeg
    if label(i) == 0, continue; end
    ind = [i find(D(i, :) < LargeNum)];
    Ds = D(ind,ind);
    for j = 1:length(ind)
        m = min(Ds(:));
        if m == LargeNum, break; end
        [r, c] = find(Ds==m, 1);
        label(ind(r)) = k;
        label(ind(c)) = k;
        k = k + 1;
        Ds([r c],[r c]) = LargeNum;
    end
end


mergedSeg = cont;

end