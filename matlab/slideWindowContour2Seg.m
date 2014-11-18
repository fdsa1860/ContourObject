function seg = slideWindowContour2Seg(contour, winSize)

n = length(contour);
winSize = 2 * floor(winSize/2) + 1;  % force winSize to be odd interger

seg = struct('points',{}, 'vel',{}, 'loc',{});
for i = 1:n
%     subseg = contour2seg(points, winSize);
    subseg = mexContour2Seg(contour(i).points, winSize);
    seg = [seg subseg];
end

end