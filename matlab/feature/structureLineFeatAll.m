function featLine = structureLineFeatAll(slope_all, points_line_all, nBins)

numImg = length(slope_all);
featLine = zeros(nBins, numImg);
for i = 1:numImg
    featLine(:, i) = structureLineFeat(slope_all{i}, points_line_all{i}, nBins);
end

end