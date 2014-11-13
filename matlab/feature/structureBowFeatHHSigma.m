function [feat, ind] = structureBowFeatHHSigma(X, centers, alpha, cells)
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
nCells = cells.num;
bbox = cells.bbox;
nc = cells.nc;
nr = cells.nr;
dim = 4*(nr-1)*(nc-1)*k;

feat = zeros(dim, 1);
ind = [];

if isempty(X),
    return;
end

locs = cat(1, X.loc);

D2 = dynamicDistanceSigmaCross(X, centers, alpha);
isInside2 = bsxfun(@ge, locs(:,1), bbox(:,1)') & ...
    bsxfun(@le, locs(:,1), bbox(:,3)') & ...
    bsxfun(@ge, locs(:,2), bbox(:,2)') & ...
    bsxfun(@le, locs(:,2), bbox(:,4)');

feat_cell = zeros(nr, nc, k);
for q = 1:nCells
    isInside = isInside2(:,q);
    D = D2(isInside,:);
    % hard voting
    [val,ind] = min(D, [], 2);
%     feat( (i-1)*k+1 : i*k ) = hist(ind, 1:k);
    
    % soft voting
    W = exp(-10*D);
%     feat( (i-1)*k+1 : i*k ) = sum(W, 1);
    i = ceil((q-0.5)/nc);
    j = mod(q-1,nc)+1;
    feat_cell(i,j,:) = sum(W, 1);
    
%     % probability voting
%     W = zeros(size(D));
%     for j = 1:k
%         W(:, j) =  exp(- centers(j).beta * D(:, j));
%     end
%     feat( (i-1)*k+1 : i*k ) = sum(W);

end

feat_block = blockNormalization(feat_cell);
feat = feat_block(:);

end