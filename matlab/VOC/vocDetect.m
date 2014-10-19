function [c,BB]=vocDetect(VOCopts, detector, cont, centers, bbs)

nbbs = size(bbs, 1);
nbbs = 100;
conf = zeros(nbbs, 1);
lb = zeros(nbbs, 1);
for i = 1:nbbs
    bb = bbs(i, 1:4);
    [feat, cont] = cont2feat_fast(cont, centers, bbs);
    [lb(i), acc, conf(i)] = svmpredict(1, sparse(feat'), detector.model, '-q');
end

pInd = conf > 0;
BB = bbs(pInd, 1:4);
c = conf(pInd);

end