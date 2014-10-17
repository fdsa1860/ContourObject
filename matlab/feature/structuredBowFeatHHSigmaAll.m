function feat = structuredBowFeatHHSigmaAll(X_all, centers, alpha, points_notLine_all, block_all, verbose)

if nargin < 6
    verbose = false;
end

if verbose
    fprintf('getting BOW representation ...');
end

nc = length(centers);
numImg = length(X_all);
nBlocks = size(block_all{1}, 1);
feat = zeros(nc * nBlocks, numImg);
for i = 1:numImg
    if isempty(X_all{i})
        continue;
    end
    feat(:,i) = structureBowFeatHHSigma(X_all{i}, centers, alpha, points_notLine_all{i}, block_all{i});
end

if verbose
    fprintf('finish!\n');
end

end