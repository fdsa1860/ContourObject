function slope = slopeEst(seg)

numSeg = length(seg);
slope = zeros(1, numSeg);
for i = 1:numSeg
    dy = seg{i}(end, 1) - seg{i}(1, 1);
    dx = seg{i}(end, 2) - seg{i}(1, 2);
    slope(i) = atan(dy/dx);
end

end