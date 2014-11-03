% chop the contour trajectories into contour segments with the same length

function [contour_new] = slideWindowChopContour_fast(contour, winSize)

h = [-1 0 0 0 1]';

n = numel(contour);
contour_new(1:n) = struct('points',[], 'seg',[]);

halfWinSize = floor(winSize/2);
winSize = 2 * halfWinSize + 1;  % force winSize to be odd interger

for i = 1:n
    points = contour{i};
    if isempty(points), keyboard; end
    L = size(points, 1);
    nseg = L - winSize + 1;
    seg(1:nseg) = struct('points',[],'vel',[],'loc',[0 0]);
    for j = 1:nseg
        seg(j).points = points(j:j+winSize-1,:);
        seg(j).vel = conv2(seg(j).points, h, 'valid');
        seg(j).loc = points(j+halfWinSize, [2 1]);
        if isempty(seg(j).vel), keyboard; end
    end
    contour_new(i).points = points;
    contour_new(i).vel = conv2(points, h, 'valid');
    contour_new(i).seg = seg;
    seg = struct('points',[],'vel',[],'loc',[]);
end

end