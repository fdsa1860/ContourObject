function [seg, shortSeg] = contour2segMS(points, opt)

% h = [-1 0 0 0 1]';
% vel = conv2(points, h, 'valid');

h = fspecial('average',[4 1]);
vel = diff(points);
isClosed = ~any(points(1,:)-points(end,:));
if isClosed
    vel = imfilter(vel, h, 'circular');
else
    vel = imfilter(vel, h, 'replicate');
end
% vel = 4*vel;

order = 6;
epsilon = 0.075;
[x, label] = indep_dyn_switch_detect1(vel,inf,epsilon,order);
label = [label(1)*ones(1,order) label];
uLabel = unique(label);
nL = length(uLabel);

seg(1:100) = struct('points',[],'vel',[],'loc',[0 0]);
shortSeg(1:100) = struct('points',[],'vel',[],'loc',[0 0]);
count = 1;
sCount = 1;
for j = 1:nL
    if nnz(label==j) < opt.minLen
        ind1 = find(label==j, 1, 'first');
        ind2 = find(label==j, 1, 'last');
        shortSeg(sCount).points = points(ind1:ind2, :);
        shortSeg(sCount).vel = vel(ind1:ind2, :);
        sCount = sCount + 1;
        continue;
    end
    ind1 = find(label==j, 1, 'first');
    ind2 = find(label==j, 1, 'last');
    seg(count).vel = vel(ind1:ind2, :);
    seg(count).points = points(ind1:ind2, :);
    count = count + 1;
end
shortSeg(sCount:end) = [];
seg(count:end) = [];

if opt.draw
    color = hsv(nL);
    figure;plot(points(:,2), points(:,1),'.');hold on;
    set(gca,'YDir','reverse');
    for j = 1:nL-1
        ind = find(label==j);
        for i=1:length(ind)
            plot(points(ind(i),2), points(ind(i),1),'.','MarkerEdgeColor',color(j,:));
        end
    end
    hold off;
end

end