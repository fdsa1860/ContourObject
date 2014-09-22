% Extract contours from a binary image

function contour = extractContBW2(BW, E)

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
k=1;
endpoint=[row';col']';

[row, column]=find(BW > 1);
all_p=[row'; column']';

while (~isempty(all_p))
    if isempty(endpoint)
        % all_p store all the begining point
        i = all_p(1,:);
        contourz = bwtraceboundary(BW, i, 'W', 8, 2000,'clockwise');
        % sepatate the contourz for two parts, and use both of them as the same
        % trajectory from different direction
        % contourz_half is the first half and contourz_half1 is the seconde half
        % if there is an wheel in the image there is no beginning point we directly
        % set contourz_half information to contourz
        contourz_half=contourz;
%         contourz_half1=[];
    else
        i=endpoint(1,:);
        contourz = bwtraceboundary(BW, i, 'W', 8, 2000,'clockwise');
        contourz_half=contourz(1:floor(length(contourz)/2),:);
        %           contourz_half1=contourz(floor(length(contourz)/2)+1:length(contourz),:);
        contourz = [contourz_half;
            %                      contourz_half1;
                    endpoint(1,:)];
        
    end
    
    %     estimate the contour is empty or not, if not the point in each
    %     trajectory should longer than 15
    if(~isempty(contourz))
        if(size(contourz_half,1)>=min_len)
            contour{k}=contourz_half;
            k=k+1;
        end
%         if(size(contourz_half1,1)>=min_len)
%             contour{k}=contourz_half1;
%             k=k+1;
%         end
        
        for n = 1:length(contourz)
            BW(contourz(n,1),contourz(n,2)) = 0;
        end
        [row1,col1]=find(BW==1);
        endpoint=[row1,col1];
        [row,column]=find(BW > 1);
        all_p=[row';column']';
    else
        all_p(1,:)=[];
    end
    
end
contour = contour';

end