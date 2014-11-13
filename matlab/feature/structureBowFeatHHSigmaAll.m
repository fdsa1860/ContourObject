function feat = structureBowFeatHHSigmaAll(X_all, centers, alpha, cells_all, verbose)

if nargin < 6
    verbose = false;
end

if verbose
    fprintf('getting BOW representation ...');
end

k = length(centers);
numImg = length(X_all);
% nBlocks = cells_all{1}.num;
% featSize = nBlocks * k;
featSize = 4 * (cells_all{1}.nr-1) * (cells_all{1}.nc-1) * k;
feat = zeros(featSize, numImg);
for i = 1:numImg
    if isempty(X_all{i})
        continue;
    end
    feat(:,i) = structureBowFeatHHSigma(X_all{i}, centers, alpha, cells_all{i});
end

if verbose
    fprintf('finish!\n');
end

end