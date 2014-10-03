function feat = structureBowFeatHHSigma(X_HH, centers_HH, X_sigma, centers_sigma, alpha, pts, block)
% Input:
% HH1: 1 by N cell, data to be represented
% HH2: 1 by K cell, cluster centers
% sigma1: D by N vector
% sigma2: D by K vector
% alpha: the weight of order in distance metric
% Output:
% feat: bag of words representation

if nargin < 5
    alpha = 1;
end

k = length(centers_HH);
nBlocks = size(block, 1);
feat = zeros(nBlocks * k, 1);

for i = 1:nBlocks
    isInside = pts(:, 1)>=block(i, 1) & pts(:, 1)<=block(i, 3) & ...
        pts(:, 2)>=block(i, 2) & pts(:, 2)<=block(i, 4);
    % get distance matrix D
    D = dynamicDistanceSigmaCross(X_HH(isInside), centers_HH, X_sigma, centers_sigma, alpha);
    [val,ind] = min(D, [], 2);
    % get BOW representation
    feat( (i-1)*k+1 : i*k ) = hist(ind, 1:k);
end

end