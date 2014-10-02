function slope_all = slopeEstAll(seg_line_all)

numImg = length(seg_line_all);
slope_all = cell(1, numImg);
for i = 1:numImg
    slope_all{i} = slopeEst(seg_line_all{i});
end

end