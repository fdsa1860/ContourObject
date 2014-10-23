function [c,BB]=vocDetect(VOCopts, detector, cont, centers, bbs, I)



maxNum = 1000;
n = min(maxNum, size(bbs, 1));
bbs = bbs(1:n, :);
bbs = [bbs(:,1) bbs(:,2) bbs(:,1)+bbs(:,3) bbs(:,2)+bbs(:,4) bbs(:,5)];
% [feat] = cont2feat_fast(cont, centers, bbs);
% [~, ~, conf] = svmpredict(ones(size(feat, 2), 1), sparse(feat'), detector.model, '-q');

conf = zeros(n, 1);
for i = 1:n
    bb = bbs(i, 1:4);
    roi = I(bb(2):bb(4), bb(1):bb(3), :);
    roiScale = imresize(roi, [128, 64]);
    cont = img2cont(roiScale, 0);
    feat = cont2feat(cont, centers, [1 1 bb(3)-bb(1)+1 bb(4)-bb(2)+1]);
    [~, ~, conf(i)] = svmpredict(ones(size(feat, 2), 1), sparse(feat'), detector.model, '-q');
end

BB = bbs(:, 1:4);
c = conf;
% c = bbs(:, 5);

end