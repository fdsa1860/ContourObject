function P = normalize_by_row(W)
% 
% using mex function to normalize by row
% s = sum(W, 2);
% P = W ./ (s * ones(1, size(W,1)));

D = sum(W, 2);
Dinv = 1./(D+eps);
P = spmtimesd(W,Dinv,[]);


