function mergedCont = mergeContour(cont)
% merge contours into longer contours with hankel metric
% Input:
% cont: n-by-1 cell arrays
% Output:
% mergedCont: m-by-1 cell arrays

eta_thr = 0.3;
maxLen = 15;
LargeNum = 100;
numSeg = length(cont);
label = zeros(numSeg, 1);
D = zeros(numSeg);
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
            D(i, j) = LargeNum;
        else
        seg2 = [seg{i}(end:-1:2, :); seg{j}];
        [seg2_tmp,~,~,rr(i, j)] = fast_incremental_hstln_mo(seg2',eta_thr);
        D(i, j) =  2 * rr(i, j) - r(i) - r(j);
        end
    end
end
D = D + D' + LargeNum * eye(numSeg);
% label groups using D
k = 1;
for i = 1:numSeg
    if label(i) ~= 0, continue; end
    ind = [i find(D(i, :) < LargeNum)];
    Ds = D(ind,ind);
    while ~all(label(ind))
        m = min(Ds(:));
        if m == LargeNum
            j = find(label(ind)==0, 1);
            label(ind(j)) = k;
            k = k + 1;
            break; 
        end
        [r, c] = find(Ds==m, 1);
        if m > 2
            label(ind(r)) = k;
            label(ind(c)) = k + 1;
            k = k + 2;
        else
            label(ind(r)) = k;
            label(ind(c)) = k;
            k = k + 1;
        end
        Ds([r c], :) = LargeNum;
        Ds(:, [r c]) = LargeNum;
    end
end
% group together same but reversed contour
len = cellfun(@length, cont);
for i = 1:numSeg
    for j = i+1:numSeg
        if len(i)~=len(j), continue; end
        if nnz(cont{i}-cont{j}(end:-1:1, :))==0 && label(i)~=label(j)
            label(label == label(j)) = label(i);
        end
    end
end
uLabel = unique(label);
tmp = zeros(size(label));
for i = 1:length(uLabel)
    tmp(label == uLabel(i)) = i;
end
label = tmp;
% merge contours
numCont = length(unique(label));
mergedCont = cell(numCont, 1);

for i = 1:numCont
    currCont = {};
    ind = find(label == i);
    for j = 1:length(ind)
        if isempty(currCont)
            currCont = cont{ind(j)};
            continue;
        end
        isValid = ismember(cont{ind(j)}, currCont, 'rows');
        isValid2 = ismember(currCont, cont{ind(j)}, 'rows');
        if nnz(isValid) == len(ind(j)), continue; end
        assert(nnz(isValid) <= 2);
        assert(nnz(isValid2) <= 2);
        if isValid(1) && isValid2(1)
            currCont = [cont{ind(j)}(end:-1:2, :); currCont];
        elseif isValid(1) && isValid2(end)
            currCont = [currCont; cont{ind(j)}(2:end, :)];
        elseif isValid(end) && isValid2(1)
            currCont = [cont{ind(j)}(1:end-1, :); currCont];
        elseif isValid(end) && isValid2(end)
            currCont = [currCont; cont{ind(j)}(end-1:-1:1, :)];
        else
            error('something goes wrong\n');
        end
    end
    mergedCont{i} = currCont;
end

end