function feat = structureBowFeatHHSigma(X, centers, alpha, pts, block)
% Input:
% X: 1 by N cell, data to be represented
% centers: 1 by K cell, cluster centers
% sigma1: D by N vector
% sigma2: D by K vector
% alpha: the weight of order in distance metric
% Output:
% feat: bag of words representation

if nargin < 5
    alpha = 0;
end

k = length(centers);
nBlocks = size(block, 1);
feat = zeros(nBlocks * k, 1);

for i = 1:nBlocks
    isInside = pts(:, 1)>=block(i, 1) & pts(:, 1)<=block(i, 3) & ...
        pts(:, 2)>=block(i, 2) & pts(:, 2)<=block(i, 4);
    % get distance matrix D: n-by-k matrix
    D = dynamicDistanceSigmaCross(X(isInside), centers, alpha);
    
%     % hard voting
%     [val,ind] = min(D, [], 2);
%     feat( (i-1)*k+1 : i*k ) = hist(ind, 1:k);

    % soft voting
    W = exp(-10*D);
    feat( (i-1)*k+1 : i*k ) = sum(W, 1);
    
%     % probability voting
%     W = zeros(size(D));
%     for j = 1:k
%         W(:, j) =  exp(- centers(j).beta * D(:, j));
%     end
%     feat( (i-1)*k+1 : i*k ) = sum(W);

end

end