function [Y_all] = buildHankelAll(X_all, hankel_size, mode, verbose)
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
Y_all = cell(1, numImg);
for i = 1:numImg
    X = X_all{i};
    numSeg = length(X);
    if numSeg == 0
        continue;
    end
    seg(1:numSeg) = struct('dsca',[], 'H',[], 'HH',[]);
    for j = 1:numSeg
        seg(j).dsca = X{j};
        [seg(j).H, seg(j).HH] = buildHankel(X{j}, hankel_size, mode);
    end
    Y_all{i} = seg;
    seg = struct('dsca',[], 'H',[], 'HH',[]);
end

if verbose
    fprintf('finish!\n');
end

end