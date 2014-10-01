% chop the contour trajectories into contour segments with the same length

function [segment, segment_id] = slideWindowChopContour(X, winSize)

n = numel(X);
nseg = 1;
halfWinSize = floor(winSize/2);
winSize = 2 * halfWinSize + 1;  % force winSize to be odd interger
N = cellfun(@length, X);
numSeg = sum(N - winSize + 1);
segment = cell(1, numSeg);
segment_id = zeros(1, numSeg);

for i = 1:n
    L = size(X{i}, 1);
    for j = halfWinSize+1:L-halfWinSize
        segment{nseg} = X{i}(j-halfWinSize:j+halfWinSize, :);
        segment_id(nseg) = i;
        nseg = nseg + 1;
    end
end

end