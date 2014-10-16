function [centers, label, D] = nCutContourHHSigma(X, sigma, H, HH, k, alpha, D)
% nCutContourHHSigma: cluster data using hankelet metric and normalized
% sigular values
%
% Input:
% X: an N-by-1 cell vector, data to cluster
% sigma: N-by-1 vector, the normalized singular value information of X
% H: N-by-1 cell, the hankel matrix of each X
% HH: N-by-1 cell, the normalized hankel matrix of each X
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

if nargin < 5
    k = numel(unique(sigma));
end

if nargin < 6
    alpha = 1;
end

if nargin < 7
    D = dynamicDistanceSigma(HH, 1:length(sigma), sigma, alpha);
end

centers(1:k) = struct('centerInd',  0,  ...
                        'data',     [], ...
                        'sigma',    [], ...
                        'H',        [], ...
                        'HH',       [],    ...
                        'beta',     0);

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

for i = 1:k
    ind = centerInd(i);
    centers(i).centerInd = ind;
    centers(i).data = X{ind};
    centers(i).sigma = sigma(:, ind);
    centers(i).H = H{ind};
    centers(i).HH = HH{ind};
    centers(i).beta = beta(i);
end

end