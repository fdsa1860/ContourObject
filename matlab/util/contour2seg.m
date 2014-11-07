function seg = contour2seg(points, winSize)

h = [-1 0 0 0 1]';

halfWinSize = floor(winSize/2);
winSize = 2 * halfWinSize + 1;  % force winSize to be odd interger

L = size(points, 1);
nseg = L - winSize + 1;
seg(1:nseg) = struct('points',[],'vel',[],'loc',[0 0]);
for j = 1:nseg
    seg(j).points = points(j:j+winSize-1,:);
    seg(j).vel = conv2(seg(j).points, h, 'valid');
    seg(j).loc = points(j+halfWinSize, [2 1]);
    if isempty(seg(j).vel), keyboard; end
end

end