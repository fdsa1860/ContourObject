function feat = structuredBowFeatHHSigmaAll(X_all_HH, X_all_sigma, centers, alpha, points_notLine_all, block_all, verbose)

if nargin < 7
    verbose = false;
end

if verbose
    fprintf('getting BOW representation ...');
end

nc = length(centers.centerInd);
numImg = length(X_all_HH);
nBlocks = size(block_all{1}, 1);
feat = zeros(nc * nBlocks, numImg);
for i = 1:numImg
    if isempty(X_all_HH{i})
        continue;
    end
    feat(:,i) = structureBowFeatHHSigma(X_all_HH{i}, X_all_sigma{i}, centers, alpha, points_notLine_all{i}, block_all{i});
end

if verbose
    fprintf('finish!\n');
end

end