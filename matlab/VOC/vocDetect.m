function [c,BB]=vocDetect(VOCopts, detector, cont, centers, bbs)

nbbs = size(bbs, 1);
% nbbs = 100;
conf = zeros(nbbs, 1);
lb = zeros(nbbs, 1);
tic
for i = 1:nbbs
    bb = bbs(i, 1:4);
    [feat2(:,i), cont] = cont2feat(cont, centers, bb);
end
toc
tic
[feat, cont] = cont2feat_fast(cont, centers, bbs);
toc
[lb, acc, conf] = svmpredict(ones(size(feat, 2), 1), sparse(feat'), detector.model, '-q');

pInd = conf > 0;
BB = bbs(pInd, 1:4);
c = conf(pInd);

end