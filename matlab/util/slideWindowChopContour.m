% chop the contour trajectories into contour segments with the same length

function [seg1, seg2, centers, seg_id1, seg_id2] = slideWindowChopContour(X1, X2, winSize)

n = numel(X1);

halfWinSize = floor(winSize/2);
winSize = 2 * halfWinSize + 1;  % force winSize to be odd interger
N = cellfun(@length, X1);
numSeg = sum(N - winSize + 1);
seg1 = cell(1, numSeg);
seg2 = cell(1, numSeg);
centers = zeros(numSeg, 2);
seg_id1 = zeros(1, numSeg);
seg_id2 = zeros(1, numSeg);

nseg = 1;
for i = 1:n
    L = size(X1{i}, 1);
    for j = halfWinSize+1:L-halfWinSize
        seg1{nseg} = X1{i}(j-halfWinSize:j+halfWinSize, :);
        seg2{nseg} = X2{i}(j-halfWinSize:j+halfWinSize, :);
        centers(nseg, :) = X2{i}(j, :);
        seg_id1(nseg) = i;
        seg_id2(nseg) = i;
        nseg = nseg + 1;
    end
end

end