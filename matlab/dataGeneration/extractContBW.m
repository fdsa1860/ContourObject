% Extract contours from a binary image

function contour = extractContBW(BW)

contour = {};
k = 1;
min_len = 10;

% delete trivial endpoint
contourz_all = bwboundaries(BW, 4);
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
    indToErase = sub2ind(size(BW), contourz(ind,1), contourz(ind,2));
    BW(indToErase) = 0;
end

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
    indToErase = sub2ind(size(BW), contourz(ind,1), contourz(ind,2));
    BW(indToErase) = 0;
end

cont_filter = [
    0 1 0;
    1 1 0;
    0 0 -1];
tmp_bw = conv2(BW, cont_filter, 'same');
BW(tmp_bw == 3) = 0;

cont_filter = [
    0 1 0;
    0 1 1;
    -1 0 0];
tmp_bw = conv2(BW, cont_filter, 'same');
BW(tmp_bw == 3) = 0;

cont_filter = [
    0 0 -1;
    1 1 0;
    0 1 0];
tmp_bw = conv2(BW, cont_filter, 'same');
BW(tmp_bw == 3) = 0;

cont_filter = [
    -1 0 0;
    0 1 1;
    0 1 0];
tmp_bw = conv2(BW, cont_filter, 'same');
BW(tmp_bw == 3) = 0;

% acquire the contours
cont_filter = [1 1 1;
    1 0 1;
    1 1 1];
tmp_bw = conv2(BW, cont_filter, 'same');
tmp_bw = tmp_bw.*BW;
[row, col] = find(tmp_bw == 1);
endpoint = [row col];
[row, col]=find(tmp_bw > 0);
all_p=[row col];

contourz_all = bwboundaries(BW, 8);
len = cellfun(@length, contourz_all);
contourz_all(len < 5) = [];
for i = 1:length(contourz_all)
    contourz = contourz_all{i};
    while ~isempty(contourz)
        indToErase = sub2ind(size(BW), contourz(:,1), contourz(:,2));
        BW(indToErase) = 0;
        isValid = ismember(contourz, endpoint, 'rows') & ~ismember(contourz, contourz(1,:), 'rows');
        ind = find(isValid, 1);
        if ~isempty(ind)
            ind_pre = ind;
            ind_nxt = ind;
            while  all(contourz(ind_pre, :) == contourz(ind_nxt, :))
                ind_pre = ind_pre - 1;
                ind_nxt = ind_nxt + 1;
                if ind_pre < 1 || ind_nxt > size(contourz, 1)
                    break;
                end
            end
            % add to contour if its length > maxLen
            if((ind_nxt-ind_pre)/2 >= min_len)
                contourz_firsthalf = contourz(ind_pre+1:ind, :);
                contourz_secondhalf = contourz(ind:ind_nxt-1, :);
                contour{k} = contourz_firsthalf;
                k = k + 1;
            end
            % remove the segment while keep the connection
            contourz(ind_pre+2:ind_nxt-1, :) = [];
            if size(contourz, 1) == 1
                contourz = [];
            end
        else
            if size(contourz, 1) >= min_len
                contour{k} = contourz;
                k = k + 1;
            end
            contourz = [];
        end
    end
end

contour = contour';

end