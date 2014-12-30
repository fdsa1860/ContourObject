function [c,BB]=vocDetectHOG(VOCopts, detector, I, bbs)

maxNum = 1000;
n = min(maxNum, size(bbs, 1));
bbs = bbs(1:n, :);
bbs = [bbs(:,1) bbs(:,2) bbs(:,1)+bbs(:,3) bbs(:,2)+bbs(:,4) bbs(:,5)];

numROI = size(bbs, 1);
feat = zeros(64/8 * (64/8) * 4*9, numROI);
for i = 1:numROI
    bb = bbs(i, 1:4);
    roi = I(bb(2):bb(4), bb(1):bb(3), :);
    try
        roiScale = imresize(roi, [64, 64]);
    catch me
        keyboard;
    end
    H = hog(single(roiScale),8,9);
    feat(:, i) = H(:);
end
[~, ~, conf] = predict(ones(size(feat, 2), 1), sparse(feat'), detector.model, '-q');
% numModel = length(detector.model);
% for i = 1:4
%     if isempty(feat), break; end
%     [lb, ~, conf] = predict(ones(size(feat, 2), 1), sparse(feat'), detector.model{i}, '-q');
%     feat(:, lb==-1) = [];
%     conf(lb==-1) = [];
%     bbs(lb==-1, :) = [];
% end

% pInd = conf > 0;
% BB = bbs(pInd, 1:4);
% c = conf(pInd);

assert(size(bbs, 1)==length(conf));
BB = bbs(:, 1:4);
c = conf;
% c = bbs(:, 5);

end