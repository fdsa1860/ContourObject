
function seg = splitContour(data,segLen)
% split contours into segments
seg = cell(300,1);
cnt = 1;
for di = 1:length(data)
    datLen = size(data{di},1);
    ind1 = 1;
    ind2 = 0;
    while ind2 < datLen
        ind1 = ind2+1;
        ind2 = min(ind1+segLen-1,datLen);
        seg{cnt} = data{di}(ind1:ind2,:);
        cnt = cnt + 1;
    end
    
    % delete short contours
    if ind1==1
        cnt = cnt - 1;
        seg{cnt} = [];
        continue;
    end
    % combine the last short segment to its previous segment
    cnt = cnt - 1;
    seg{cnt-1} = [seg{cnt-1};seg{cnt}];
    seg{cnt} = [];
end

indEmpty = cellfun(@isempty,seg);
seg(indEmpty) = [];