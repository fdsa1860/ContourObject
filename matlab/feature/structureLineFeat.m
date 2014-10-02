function [featLine, ind] = structureLineFeat(slope, points, nBins)

nr = 2;
nc = 2;
winWidth = 16;
winHeight = 16;


step = pi / nBins;
ind = ceil((slope + pi/2) / step);
featLine = hist(ind, 1:nBins);

end