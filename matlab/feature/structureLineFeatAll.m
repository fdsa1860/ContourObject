function featLine = structureLineFeatAll(slope_all, nBins, points_line_all, cells_all)

numImg = length(slope_all);
nBlocks = cells_all{1}.num;
featLine = zeros(nBins * nBlocks, numImg);
for i = 1:numImg
    if isempty(slope_all{i})
        continue;
    end
    featLine(:, i) = structureLineFeat(slope_all{i}, nBins, points_line_all{i}, cells_all{i});
end

end