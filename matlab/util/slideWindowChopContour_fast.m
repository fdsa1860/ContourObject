% chop the contour trajectories into contour segments with the same length

function [contour_new] = slideWindowChopContour_fast(contour, winSize)

h = [-1 0 0 0 1]';

n = numel(contour);
contour_new(1:n) = struct('points',[], 'vel',[], 'seg',[]);
winSize = 2 * floor(winSize/2) + 1;  % force winSize to be odd interger

for i = 1:n
    points = contour{i};
    contour_new(i).points = points;
    contour_new(i).vel = conv2(points, h, 'valid');
    contour_new(i).seg = mexContour2Seg(points, winSize);
end

end