function feat = structureFeat(seg, block)

k = seg.featLen;
nBlocks = size(block, 1);
feat = zeros(nBlocks * k, 1);
pts = cat(1, seg.points);

for i = 1:nBlocks
    isInside = pts(:, 1)>=block(i, 1) & pts(:, 1)<=block(i, 3) & ...
        pts(:, 2)>=block(i, 2) & pts(:, 2)<=block(i, 4);
    W = cat(1, seg(isInside).feat);
    f = sum(W);
    f(seg.lineFeatInd) = l2Normalization(f(seg.lineFeatInd));
    f(seg.notLineFeatInd) = l2Normalization(f(seg.notLineFeatInd));
    feat( (i-1)*k+1 : i*k ) = f;
    
%     % probability voting
%     W = zeros(size(D));
%     for j = 1:k
%         W(:, j) =  exp(- centers(j).beta * D(:, j));
%     end
%     feat( (i-1)*k+1 : i*k ) = sum(W);

end

end