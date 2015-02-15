function seg = contour2seg(points, winSize)

h = [-1 0 0 0 1]';

halfWinSize = floor(winSize/2);
winSize = 2 * halfWinSize + 1;  % force winSize to be odd interger
L = size(points, 1);
isClosed = all(points(1,:)==points(end,:));

if ~isClosed
    nseg = L - winSize + 1;
    seg(1:nseg) = struct('points',[],'vel',[],'loc',[0 0]);
    for j = 1:nseg
        seg(j).points = points(j:j+winSize-1,:);
        seg(j).vel = conv2(seg(j).points, h, 'valid');
        seg(j).loc = seg(j).points(halfWinSize+1, [2 1]);
        if isempty(seg(j).vel), error('seg(j).vel is empty\n'); end
    end
else
    nseg = L - 1;
    seg(1:nseg) = struct('points',[],'vel',[],'loc',[0 0]);
    for j = 1:nseg
        ind = j:j+winSize-1;
        ind = mod(ind-1, L-1) + 1;
        seg(j).points = points(ind,:);
        seg(j).vel = conv2(seg(j).points, h, 'valid');
        seg(j).loc = seg(j).points(halfWinSize+1, [2 1]);
        if isempty(seg(j).vel), error('seg(j).vel is empty\n'); end
    end
end

end