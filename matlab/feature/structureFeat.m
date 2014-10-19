function feat = structureFeat(seg, block)

if isempty(seg)
    feat = [];
    return;
end

k = seg(1).featLen;
nBlocks = size(block, 1);
feat = zeros(nBlocks * k, 1);
pts = cat(1, seg.points);
isLine = repmat(seg(1).lineFeatInd,[nBlocks, 1]);

for i = 1:nBlocks
    isInside = pts(:, 1)>=block(i, 1) & pts(:, 1)<=block(i, 3) & ...
        pts(:, 2)>=block(i, 2) & pts(:, 2)<=block(i, 4);
    if ~any(isInside)
        continue;
    end
    W = cat(2, seg(isInside).feat);
    f = sum(W, 2);

    feat( (i-1)*k+1 : i*k ) = f;
    
%     % probability voting
%     W = zeros(size(D));
%     for j = 1:k
%         W(:, j) =  exp(- centers(j).beta * D(:, j));
%     end
%     feat( (i-1)*k+1 : i*k ) = sum(W);

end

feat(isLine) = l2Normalization(feat(isLine));
feat(~isLine) = l2Normalization(feat(~isLine));

end