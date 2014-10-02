function [H_all, HH_all] = buildHankelAll(X_all, hankel_size, mode, verbose)
% Input:
% X_all: data to build hankel matrix
% hankel_size: when mode 1, number of rows of hankel matrix, when mode 2,
% it is the number of columns of hankel matrix
% mode: 1 if number of rows of hankel is fixed, 2 if number of columns is
% fixed
% Output:
% H_all: the hankel matrix H
% HH_all: it is H*H' if mode is 1; it is H'*H if mode is 2

if nargin < 4
    verbose = false;
end

if verbose
    fprintf('building hankel matrices ...');
end

numImg = length(X_all);
H_all = cell(1, numImg);
HH_all = cell(1, numImg);
for i = 1:numImg
    X = X_all{i};
    numSeg = length(X);
    if numSeg == 0
        H_all{i} = [];
        HH_all{i} = [];
        continue;
    end
    H = cell(1, numSeg);
    HH = cell(1, numSeg);
    for j = 1:numSeg
        [H{j}, HH{j}] = buildHankel(X{j}, hankel_size, mode);
    end
    H_all{i} = H;
    HH_all{i} = HH;
end

if verbose
    fprintf('finish!\n');
end

end