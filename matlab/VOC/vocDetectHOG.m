function [c,BB]=vocDetectHOG(VOCopts, detector, I, bbs)

maxNum = 1000;
n = min(maxNum, size(bbs, 1));
bbs = bbs(1:n, :);

numROI = size(bbs, 1);
feat = zeros(128/8 * (64/8) * 4*9, numROI);
for i = 1:numROI
    bb = bbs(i, 1:4);
    roi = I(bb(2):bb(2)+bb(4), bb(1):bb(1)+bb(3), :);
    try
    roiScale = imresize(roi, [128, 64]);
    catch me
        keyboard;
    end
    H = hog(roiScale,8,9);
    feat(:, i) = H(:);
end
[~, ~, conf] = svmpredict(ones(size(feat, 2), 1), sparse(feat'), detector.model, '-q');

% pInd = conf > 0;
% BB = bbs(pInd, 1:4);
% c = conf(pInd);

BB = bbs(:, 1:4);
c = conf;
% c = bbs(:, 5);

end