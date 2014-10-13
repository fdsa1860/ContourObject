% Extract contours from a binary image

function contour = extractContBW(BW)

k = 1;
minLen = 5;
maxContourNum = 10000;
contour = cell(maxContourNum, 1);

% delete trivial endpoint
cont_filter1 = [
    0 0 0;
    0 1 0;
    1 1 1];
cont_filter2 = [
    1 1 1;
    1 0 1;
    0 0 0];
tmp_bw1 = conv2(BW, cont_filter1, 'same');
tmp_bw2 = conv2(BW, cont_filter2, 'same');
BW(tmp_bw1==4 & tmp_bw2==0) = 0;
tmp_bw1 = conv2(BW, rot90(cont_filter1), 'same');
tmp_bw2 = conv2(BW, rot90(cont_filter2), 'same');
BW(tmp_bw1==4 & tmp_bw2==0) = 0;
tmp_bw1 = conv2(BW, rot90(cont_filter1, 2), 'same');
tmp_bw2 = conv2(BW, rot90(cont_filter2, 2), 'same');
BW(tmp_bw1==4 & tmp_bw2==0) = 0;
tmp_bw1 = conv2(BW, rot90(cont_filter1, 3), 'same');
tmp_bw2 = conv2(BW, rot90(cont_filter2, 3), 'same');
BW(tmp_bw1==4 & tmp_bw2==0) = 0;

cont_filter3 = [
    0 1 0;
    1 1 0;
    0 0 0];
cont_filter4 = [
    1 1 1;
    1 0 1;
    1 1 1];
tmp_bw3 = conv2(BW, cont_filter3, 'same');
tmp_bw4 = conv2(BW, cont_filter4, 'same');
[r, c] = find(tmp_bw3==3);
n = length(r);
Index = [sub2ind(size(BW),r,c) sub2ind(size(BW),r+1,c) sub2ind(size(BW),r,c+1)];
M = tmp_bw4(Index);
[~, ind] = min(M, [], 2);
I = sparse(1:n, ind, true, n, 3);
BW(Index(I)) = 0;

tmp_bw3 = conv2(BW, rot90(cont_filter3), 'same');
tmp_bw4 = conv2(BW, cont_filter4, 'same');
[r, c] = find(tmp_bw3==3);
n = length(r);
Index = [sub2ind(size(BW),r,c) sub2ind(size(BW),r-1,c) sub2ind(size(BW),r,c+1)];
M = tmp_bw4(Index);
[~, ind] = min(M, [], 2);
I = sparse(1:n, ind, true, n, 3);
BW(Index(I)) = 0;

tmp_bw3 = conv2(BW, rot90(cont_filter3, 2), 'same');
tmp_bw4 = conv2(BW, cont_filter4, 'same');
[r, c] = find(tmp_bw3==3);
n = length(r);
Index = [sub2ind(size(BW),r,c) sub2ind(size(BW),r-1,c) sub2ind(size(BW),r,c-1)];
M = tmp_bw4(Index);
[~, ind] = min(M, [], 2);
I = sparse(1:n, ind, true, n, 3);
BW(Index(I)) = 0;

tmp_bw3 = conv2(BW, rot90(cont_filter3, 3), 'same');
tmp_bw4 = conv2(BW, cont_filter4, 'same');
[r, c] = find(tmp_bw3==3);
n = length(r);
Index = [sub2ind(size(BW),r,c) sub2ind(size(BW),r+1,c) sub2ind(size(BW),r,c-1)];
M = tmp_bw4(Index);
[~, ind] = min(M, [], 2);
I = sparse(1:n, ind, true, n, 3);
BW(Index(I)) = 0;

% delete trivial endpoint
contourz_all = bwboundaries(BW, 8);
len = cellfun(@length, contourz_all);
contourz_all(len < 5) = [];
for i = 1:length(contourz_all)
    contourz = contourz_all{i};
    hit = false(size(contourz, 1), 1);
    d1 = sum(abs(contourz(1:end-2,:) - contourz(3:end,:)), 2);
    d2 = sum(abs(contourz(1:end-4,:) - contourz(5:end,:)), 2);
    d3 = sum(abs(contourz(2,:) - contourz(end-1,:)));
    d4 = sum(abs(contourz(3,:) - contourz(end-2,:)));
    hit(3:end-2) = (d1(2:end-1)==0 & d2~=0);
    hit(2) = (d1(1)==0);
    hit(end-1) = (d1(end)==0);
    hit(1) = (d3==0 && d4~=0);
    hit(end) = hit(1);
    ind = find(hit);
    if ~isempty(ind)
        indToErase = sub2ind(size(BW), contourz(ind,1), contourz(ind,2));
        BW(indToErase) = 0;
    end
end

% acquire the contours
cont_filter = [
    1 1 1;
    1 0 1;
    1 1 1];
tmp_bw = conv2(BW, cont_filter, 'same');
tmp_bw = tmp_bw.*BW;
[row, col] = find(tmp_bw == 1);
endpoint = [row col];
[row, col]=find(tmp_bw > 2);
crosspoint = [row col];


% break at cross points
contourz_all = bwboundaries(BW, 8);
len = cellfun(@length, contourz_all);
contourz_all(len < 5) = [];
for i = 1:length(contourz_all)
    
    contourz = contourz_all{i};
    % enforce contour to start and end with endpoint or crosspoint
    isEndPt = ismember(contourz, endpoint, 'rows');
    isCrossPt = ismember(contourz, crosspoint, 'rows');
    if any(isEndPt)
        offset = find(isEndPt, 1);
        contourz = circshift(contourz(1:end-1, :), 1-offset);
        contourz(end+1, :) = contourz(1, :);
    elseif any(isCrossPt)
        offset = find(isCrossPt, 1);
        contourz = circshift(contourz(1:end-1, :), 1-offset);
        contourz(end+1, :) = contourz(1, :);
    end

    isEndPt = ismember(contourz, endpoint, 'rows');
    isCrossPt = ismember(contourz, crosspoint, 'rows');
    if any(isCrossPt)
        crossPtInd = find(isCrossPt);
        endPtInd = find(isEndPt);
        if isempty(endPtInd)
            segInd = [crossPtInd(1:end-1) crossPtInd(2:end)];
        else
            segInd = zeros(nnz(isCrossPt), 2);
            sortedInd = sort([crossPtInd; endPtInd]);
            tmp = find(ismember(sortedInd, crossPtInd));
            segInd(:, 1) = crossPtInd;
            segInd(:, 2) = sortedInd(tmp + 1);
        end
        seg = cell(1, size(segInd, 1));
        for j = 1:size(segInd, 1)
            seg{j} = contourz(segInd(j, 1) : segInd(j, 2), :);
        end
        mergedSeg = mergeContour(seg);
        nMerged = length(mergedSeg);
        contour(k:k+nMerged-1) = mergedSeg;
        k = k + nMerged;
    elseif any(isEndPt)
        contour{k} = contourz(1:size(contourz,1)/2, :);
        k = k + 1;
    else
        contour{k} = contourz;
        k = k + 1;
    end
end
contour(k:end) = [];

% % break at endpoints
% minLen = 10;
% contourz_all = bwboundaries(BW, 8);
% len = cellfun(@length, contourz_all);
% contourz_all(len < 5) = [];
% for i = 1:length(contourz_all)
%     contourz = contourz_all{i};
%     while ~isempty(contourz)
%         indToErase = sub2ind(size(BW), contourz(:,1), contourz(:,2));
%         BW(indToErase) = 0;
%         isValid = ismember(contourz, endpoint, 'rows') & ~ismember(contourz, contourz(1,:), 'rows');
%         ind = find(isValid, 1);
%         if ~isempty(ind)
%             ind_pre = ind;
%             ind_nxt = ind;
%             while  all(contourz(ind_pre, :) == contourz(ind_nxt, :))
%                 ind_pre = ind_pre - 1;
%                 ind_nxt = ind_nxt + 1;
%                 if ind_pre < 1 || ind_nxt > size(contourz, 1)
%                     break;
%                 end
%             end
%             % add to contour if its length > minLen
% %             if((ind_nxt-ind_pre)/2 >= minLen)
%                 contourz_firsthalf = contourz(ind_pre+1:ind, :);
%                 contourz_secondhalf = contourz(ind:ind_nxt-1, :);
%                 contour{k} = contourz_firsthalf;
%                 k = k + 1;
% %             end
%             % remove the segment while keep the connection
%             contourz(ind_pre+2:ind_nxt-1, :) = [];
%             if size(contourz, 1) == 1
%                 contourz = [];
%             end
%         else
%             if size(contourz, 1) >= minLen
%                 contour{k} = contourz;
%                 k = k + 1;
%             end
%             contourz = [];
%         end
%     end
% end


len = cellfun(@length, contour);
contour(len < minLen) = [];

end