function feat = structuredBowFeatHHSigmaAll(X_all_HH, centers_HH, X_all_sigma, centers_sigma, alpha, points_notLine_all, block_all, verbose)

if nargin < 8
    verbose = false;
end

if verbose
    fprintf('getting BOW representation ...');
end

nc = length(centers_HH);
numImg = length(X_all_HH);
nBlocks = size(block_all{1}, 1);
feat = zeros(nc * nBlocks, numImg);
for i = 1:numImg
    if isempty(X_all_HH{i})
        continue;
    end
    feat(:,i) = structureBowFeatHHSigma(X_all_HH{i}, centers_HH, X_all_sigma{i}, centers_sigma, alpha, points_notLine_all{i}, block_all{i});
end

if verbose
    fprintf('finish!\n');
end

end