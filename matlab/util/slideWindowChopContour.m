% chop the contour trajectories into contour segments with the same length

function [seg1, seg2, centers, seg_id1, seg_id2, seg] = slideWindowChopContour(dsca, cont, winSize)

n = numel(dsca);

halfWinSize = floor(winSize/2);
winSize = 2 * halfWinSize + 1;  % force winSize to be odd interger
N = cellfun(@length, dsca);
numSeg = sum(N - winSize + 1);
seg1 = cell(1, numSeg);
seg2 = cell(1, numSeg);
centers = zeros(numSeg, 2);
seg_id1 = zeros(1, numSeg);
seg_id2 = zeros(1, numSeg);
seg = cell(1, n);

nseg = 1;
for i = 1:n
    L = size(dsca{i}, 1);
    k = 1;
    subseg1 = [];
    subseg2 = [];
    for j = halfWinSize+1:L-halfWinSize
        seg1{nseg} = dsca{i}(j-halfWinSize:j+halfWinSize, :);
        seg2{nseg} = cont{i}(j-halfWinSize:j+halfWinSize, :);
        centers(nseg, :) = cont{i}(j, [2 1]); % [r c] to [x y] format
        seg_id1(nseg) = i;
        seg_id2(nseg) = i;
        subseg1{k} = seg1{nseg};
        subseg2{k} = seg2{nseg};
        nseg = nseg + 1;
        k = k + 1;
    end
    subseg.dsca = subseg1;
    subseg.cont = subseg2;
    seg{i} = subseg;
end

end