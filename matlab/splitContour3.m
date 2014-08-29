function seg = splitContour3(data)
% split contours into segments
seg = cell(300,1);
step = 4;
minLen = 10;
thres = 2;
h = [-1 0 0 0 1]';
cnt = 1;
for di = 1:length(data)
    datLen = size(data{di},1);
    index = true(datLen,1);
%     v = diff(data{di}(1:step:end,:));
    v = conv2(data{di},h,'valid');
%     a = diff(v);
    a = conv2(v,h,'valid');
    a_abs = sum(abs(a),2);
    invalidInd = find(a_abs > thres);
%     invalidInd = invalidInd * step; % project back to original indices
    % the neighborhood of corner is ignored
    for i = 1:length(invalidInd)
%         index(max(invalidInd(i)-2,1):min(invalidInd(i)+2,datLen)) = false;
        index(invalidInd(i)+2) = false;
    end
    
    ind2 = 1;    
    while ind2 < datLen
         ind1 = ind2 + find(index(ind2:end),1) - 1;
         ind2 = ind1 + find(~index(ind1:end),1) - 1;
         if isempty(ind2)
             ind2 = datLen + 1;
         end
         seg{cnt} = data{di}(ind1:ind2-1,:);
         cnt = cnt + 1;
    end
end

indEmpty = cellfun(@isempty,seg);
seg(indEmpty) = [];

% delete short contours

index = true(length(seg),1);
for si = 1:length(seg)
    if size(seg{si},1) < minLen
        index(si) = false;
    end
end
seg = seg(index);

end

