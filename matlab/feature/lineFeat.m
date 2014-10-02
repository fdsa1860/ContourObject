function [featLine, ind] = lineFeat(slope, nBins)

step = pi / nBins;
ind = ceil((slope + pi/2) / step);
featLine = hist(ind, 1:nBins);

end