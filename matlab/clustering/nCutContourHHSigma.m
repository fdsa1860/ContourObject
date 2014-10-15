function [label, centers, cSigma, cH, cHH, D, centerInd] = nCutContourHHSigma(X, sigma, H, HH, k, alpha, D)
% Input:
% X: an N-by-1 cell vector, data to cluster
% sigma: N-by-1 vector, the normalized singular value information of X
% H: N-by-1 cell, the hankel matrix of each X
% HH: N-by-1 cell, the normalized hankel matrix of each X
% k: the number of clusters
% Output:
% label: the clustered labeling results
% centers: the cluster centers
% cSigma: the normalized singular value information of the centers
% cH: the centers' hankel matrices
% cHH: the centers' normalized hankel matrices
% k: the number of clusters

if nargin < 5
    k = numel(unique(sigma));
end

if nargin < 6
    alpha = 1;
end

if nargin < 7
    D = dynamicDistanceSigma(HH, 1:length(sigma), sigma, alpha);
end

W = exp(-D);     % the similarity matrix
NcutDiscrete = ncutW(W, k);
label = sortLabel_count(NcutDiscrete);

% D1 = D(label==1, label==1);
% W1 = exp(-D1);
% NcutDiscrete1 = ncutW(W1, k);
% label1 = sortLabel_count(NcutDiscrete1);
% label(label==1) = k + label1;
% label = sortLabel(label);

centerInd = findCenters(D, label);
centers = X(centerInd);
cSigma = sigma(:, centerInd);
cH = H(centerInd);
cHH = HH(centerInd);

end