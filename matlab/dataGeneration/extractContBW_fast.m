% Extract contours from a binary image

function contour = extractContBW_fast(BW, E)

contour = {};

cont_filter = [
    0 1 0;
    1 1 0;
    0 0 0];
tmp_bw = conv2(BW, cont_filter, 'same');
BW(tmp_bw == 3) = 0;

cont_filter = [
    0 1 0;
    0 1 1;
    0 0 0];
tmp_bw = conv2(BW, cont_filter, 'same');
BW(tmp_bw == 3) = 0;

cont_filter = [
    0 0 0;
    1 1 0;
    0 1 0];
tmp_bw = conv2(BW, cont_filter, 'same');
BW(tmp_bw == 3) = 0;

cont_filter = [
    0 0 0;
    0 1 1;
    0 1 0];
tmp_bw = conv2(BW, cont_filter, 'same');
BW(tmp_bw == 3) = 0;

% Break the contours at crossing
cont_filter = [
    1 1 1;
    1 0 1;
    1 1 1];
tmp_bw = conv2(BW, cont_filter, 'same');
tmp_bw = tmp_bw.*BW;
indx = find(tmp_bw >= 3);
nr = size(BW, 1);
nc = size(BW, 2);
neighbors = [
    indx-nr-1,indx-nr, indx-nr+1, ...
    indx-1, indx+1, ...
    indx+nr-1, indx+nr, indx+nr+1];
neighbors_sorted = zeros(size(neighbors));
[Val,Ind] = sort(E(neighbors).*BW(neighbors), 2, 'descend');
for i = 1:size(neighbors, 1)
    tmp = neighbors(i, :);
    neighbors_sorted(i, :) = tmp(Ind(i, :));
end

P = Val > 0;
P(:,1:2) = false;   % keep the two most possible connections
indToReset = neighbors_sorted(P);
BW(indToReset) = 0;

min_len = 8;

% find the beginning point of each trajectory
cont_filter = [1 1 1;
                     1 0 1;
                     1 1 1];
tmp_bw = conv2(BW, cont_filter, 'same');
BW = tmp_bw.*BW;
[row, col]=find(BW == 1);
endpoint=[row, col];

contourz_all = bwboundaries(BW, 8);
len = cellfun(@length, contourz_all);
contourz_all(len < 5) = [];
k=1;
for i = 1:length(contourz_all)
    contourz = contourz_all{i};
    isEndPt = ismember(contourz, endpoint, 'rows');
    if ~any(isEndPt)
        contourz_half=contourz;
    else
        contourz_half=contourz(1:floor(length(contourz)/2),:);
    end
    contour{k}=contourz_half;
    k=k+1;
end
contour = contour';

end