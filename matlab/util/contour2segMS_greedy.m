function [seg, shortSeg] = contour2segMS_greedy(points, opt)

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

seg(1:100) = struct('points',[],'vel',[],'loc',[0 0],'reg',[],'order',0);
shortSeg(1:100) = struct('points',[],'vel',[],'loc',[0 0],'reg',[],'order',0);
count = 1;
sCount = 1;

order = 2;
epsilon = 0.08;
% order = 2;
% epsilon = 0.075;
velSegsRem = {vel};
pointsSegsRem = {points(1:end-1,:)};

while ~isempty(velSegsRem)
    velSegsTmp = {};
    pointsSegsTmp = {};
    for k = 1:length(velSegsRem)
        vel = velSegsRem{k};
        points = pointsSegsRem{k};
        % minimum switch segmentation
        [r, label] = indep_dyn_switch_detect1(vel,inf,epsilon,order);
        % if segmentation fails, forward it to the higher order model
        if isempty(label)
            velSegsTmp = [velSegsTmp {vel}];
            pointsSegsTmp = [pointsSegsTmp {points}];
            continue;
        end
        % padding
        reg = reshape(r, order, [])';
        reg = [repmat(reg(1,:), order, 1); reg];
        label = [label(1)*ones(1,order) label];
        [uLabel,~,label] = unique(label);
        nL = length(uLabel);
        % save long segments
        v = zeros(size(vel,1), 1); % splitting indicator vector
        for j = 1:nL
            if nnz(label==j) < opt.minLen
                continue;   % ignore short segments
            end
            seg(count).vel = vel(label==j,:);
            seg(count).points = points(label==j,:);
            assert(nnz(abs(diff(reg(label==j,:)))>1e-6)==0);% regressor consistency
            seg(count).reg = reg(find(label==j,1),:);
            seg(count).order = order;
            v(label==j) = 1;
            count = count + 1;
        end
        % deal with left segments
        velSegs2 = curveSplit(vel,~v,false);
        pointsSegs2 = curveSplit(points,~v,false);
        regSegs2 = curveSplit(reg,~v,false);
        indToDel = false(length(velSegs2), 1);
        for i = 1:length(velSegs2)
            if size(velSegs2{i}, 1) >= opt.minLen
                continue;
            end
            shortSeg(sCount).points = pointsSegs2{i};
            shortSeg(sCount).vel = velSegs2{i};
            indToDel(i) = true;
            sCount = sCount + 1;
        end
        velSegs2(indToDel) = [];
        pointsSegs2(indToDel) = [];
        velSegsTmp = [velSegsTmp velSegs2];
        pointsSegsTmp = [pointsSegsTmp pointsSegs2];
    end
    velSegsRem = velSegsTmp;
    pointsSegsRem = pointsSegsTmp;
    order = order + 1;
end

shortSeg(sCount:end) = [];
seg(count:end) = [];

% seg(1:100) = struct('points',[],'vel',[],'loc',[0 0]);
% shortSeg(1:100) = struct('points',[],'vel',[],'loc',[0 0]);
% count = 1;
% sCount = 1;
% for j = 1:nL
%     if nnz(label==j) < opt.minLen
%         ind1 = find(label==j, 1, 'first');
%         ind2 = find(label==j, 1, 'last');
%         shortSeg(sCount).points = points(ind1:ind2, :);
%         shortSeg(sCount).vel = vel(ind1:ind2, :);
%         sCount = sCount + 1;
%         continue;
%     end
%     ind1 = find(label==j, 1, 'first');
%     ind2 = find(label==j, 1, 'last');
%     seg(count).vel = vel(ind1:ind2, :);
%     seg(count).points = points(ind1:ind2, :);
%     count = count + 1;
% end
% shortSeg(sCount:end) = [];
% seg(count:end) = [];

% if opt.draw
%     color = hsv(nL);
%     figure;plot(points(:,2), points(:,1),'.');hold on;
%     set(gca,'YDir','reverse');
%     for j = 1:nL
%         plot(points(label==j,2), points(label==j,1),'.','MarkerEdgeColor',color(j,:));
%     end
%     hold off;
% end

end