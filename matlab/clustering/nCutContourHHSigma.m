function [centers, label, D] = nCutContourHHSigma(X, k, alpha, D, scale_sig, order)
% nCutContourHHSigma: cluster data using hankelet metric and normalized
% sigular values
%
% Input:
% X: an N-by-1 cell vector, data to cluster
% k: the number of clusters
% alpha: the distance metric parameter, affects the significance of the
% order difference information
% D: distance matrix
% Output:
% centers.centerInd: indices of centers in D
% centers.data: the cluster centers
% centers.sigma: the normalized singular value information of the centers
% centers.H: the centers' hankel matrices
% centers.HH: the centers' normalized hankel matrices
% label: the clustered labeling results
% D: distance matrix

if nargin < 3
    alpha = 0;
end

if nargin < 4 || isempty(D)
    D = dynamicDistanceSigma(X, alpha);
end

if (~exist('scale_sig','var'))
    scale_sig = 0.001*max(D(:));
end

if (~exist('order','var'))
  order = 2;
end

tmp = (D/scale_sig).^order;
W = exp(-tmp);     % the similarity matrix
NcutDiscrete = ncutW(W, k);
label = sortLabel_count(NcutDiscrete);
% update k, sometimes the cluster # is not exactly k
k = length(unique(label));

% ncut again on the first cluster
% D1 = D(label==1, label==1);
% W1 = exp(-D1);
% NcutDiscrete1 = ncutW(W1, k);
% label1 = sortLabel_count(NcutDiscrete1);
% label(label==1) = k + label1;
% label = sortLabel(label);

centerInd = findCenters(D, label);


% estimate beta, which is the parameter for the estimated pdf of each
% cluster, the pdf function is f(x) = beta * exp(- beta * x)
delta_t = 0.0002;
t = 0:delta_t:1;
beta = zeros(1, k);
for i = 1:k
    h = hist(D(centerInd(i), label==i), t);
    p = h / sum(h * delta_t);
    beta(i) = 1 / (sum(p .* t * delta_t) + 1e-6);
end

centers = X(centerInd);
for i = 1:k
    centers(i).centerInd = centerInd(i);
    centers(i).beta = beta(i);
end

end