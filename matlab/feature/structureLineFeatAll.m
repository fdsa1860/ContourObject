function featLine = structureLineFeatAll(slope_all, nBins, points_line_all, block_all)

numImg = length(slope_all);
nBlocks = size(block_all{1}, 1);
featLine = zeros(nBins * nBlocks, numImg);
for i = 1:numImg
    if isempty(slope_all{i})
        continue;
    end
    featLine(:, i) = structureLineFeat(slope_all{i}, nBins, points_line_all{i}, block_all{i});
end

end