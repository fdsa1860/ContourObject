function seg = splitContour2(data)
% split contours into segments
seg = cell(300,1);
initLen = 10;
minLen = 20;
thres = 0.5;
cnt = 1;
for di = 1:length(data)
    datLen = size(data{di},1);
    s = data{di}';
    ind1 = 1;
    ind2 = ind1+initLen-1;
    while ind2 < datLen
        [~,~,~,R_pre] = fast_incremental_hstln_mo(s(:,ind1:ind2),thres);
        R = R_pre;
        while R == R_pre && ind2 < datLen
            ind2 = ind2 + 1;
            [~,~,~,R] = fast_incremental_hstln_mo(s(:,ind1:ind2),thres);
        end
        seg{cnt} = data{di}(ind1:ind2-1,:);
        cnt = cnt + 1;
        
        ind1 = ind2+1;
        ind2 = ind1+initLen-1;
        % [~,~,~,R(ind2)] = fast_incremental_hstln_mo(s(:,ind1:ind2),1);
        % r(ind2) = findRank(s(:,ind1:ind2),0.99);
    end
end

indEmpty = cellfun(@isempty,seg);
seg(indEmpty) = [];

% delete short contours

ind = true(length(seg),1);
for si = 1:length(seg)
    if size(seg{si},1) < minLen
        ind(si) = false;
    end
end
seg = seg(ind);

end

