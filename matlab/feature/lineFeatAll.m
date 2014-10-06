function featLine = lineFeatAll(slope_all, nBins)

numImg = length(slope_all);
featLine = zeros(nBins, numImg);
for i = 1:numImg
    if isempty(slope_all{i})
        continue;
    end
    featLine(:, i) = lineFeat(slope_all{i}, nBins);
end

end