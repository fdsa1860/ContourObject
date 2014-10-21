function [c,BB]=vocDetect(VOCopts, detector, cont, centers, bbs)

maxNum = 1000;
n = min(maxNum, size(bbs, 1));
bbs = bbs(1:n, :);
bbs = [bbs(:,1) bbs(:,2) bbs(:,1)+bbs(:,3) bbs(:,2)+bbs(:,4)];
[feat] = cont2feat_fast(cont, centers, bbs);
[~, ~, conf] = svmpredict(ones(size(feat, 2), 1), sparse(feat'), detector.model, '-q');

% pInd = conf > 0;
% BB = bbs(pInd, 1:4);
% c = conf(pInd);

BB = bbs(:, 1:4);
c = conf;
% c = bbs(:, 5);

end