% Extract contours from a binary image

function contour = extractContBW(BW)

contour = {};
k = 1;

% Break the contours at crossing
cont_filter = [1 1 1;
               1 0 1;
               1 1 1];
tmp_bw = conv2(BW, cont_filter, 'same');
tmp_bw = tmp_bw.*BW;
[row, col] = find(tmp_bw >= 3);
crosspoint = [row col];
[row, col] = find(tmp_bw == 1);
endpoint = [row col];

% delete trivial endpoint, if there is a endpoint beside a crosspoint,
% delete this endpoint
D = pdist2(crosspoint, endpoint, 'L1');
D==1

[row, col]=find(tmp_bw > 0);
all_p=[row col];

min_len = 20;

while (~isempty(all_p))
    if isempty(endpoint)
        % all_p store all the begining point
        pt = all_p(1,:);
        contourz = bwtraceboundary(BW, pt, 'W', 8, 2000,'clockwise');
        % sepatate the contourz for two parts, and use both of them as the same
        % trajectory from different direction
        % contourz_half is the first half and contourz_half1 is the seconde half
        % if there is an wheel in the image there is no beginning point we directly
        % set contourz_half information to contourz
%         contourz_half=contourz;
%         contourz_half1=[];
    else
        pt = endpoint(1,:);
        contourz = bwtraceboundary(BW, pt, 'W', 8, 2000,'clockwise');
%         contourz_half=contourz(1:floor(length(contourz)/2),:);
        %           contourz_half1=contourz(floor(length(contourz)/2)+1:length(contourz),:);
%         contourz = [contourz_half;
            %                      contourz_half1;
%                     endpoint(1,:)];
        
    end
    
    while ~isempty(contourz)
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
        end
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