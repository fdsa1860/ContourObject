function seg = contour2segMS(points, opt)

h = [-1 0 0 0 1]';
vel = conv2(points, h, 'valid');

order = 6;
epsilon = 0.3;
[x, label] = indep_dyn_switch_detect1(vel,inf,epsilon,order);
label = [zeros(1,order) label];

uLabel = unique(label);
nL = length(uLabel);
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

seg(1:100) = struct('points',[],'vel',[],'loc',[0 0]);
count = 1;
for j = 1:nL-1
    if nnz(label==j) < opt.minLen
        continue;
    end
    ind1 = find(label==j, 1, 'first');
    ind2 = find(label==j, 1, 'last');
    seg(count).vel = vel(ind1:ind2, :);
    seg(count).points = points(ind1-6:ind2, :);
    count = count + 1;
end
seg(count:end) = [];
end