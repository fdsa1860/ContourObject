function [featLine, ind] = structureLineFeat(slope, nBins, pts, cells)

bbox = cells.bbox;
nBlocks = cells.num;
featLine = zeros(nBlocks*nBins, 1);
step = pi / nBins;

for i = 1:nBlocks
    isInside = pts(:, 1)>=bbox(i, 1) & pts(:, 1)<=bbox(i, 3) & ...
        pts(:, 2)>=bbox(i, 2) & pts(:, 2)<=bbox(i, 4);
    ind = ceil((slope(isInside) + pi/2) / step);
    featLine( (i-1)*nBins+1 : i*nBins ) = hist(ind, 1:nBins);
end

end