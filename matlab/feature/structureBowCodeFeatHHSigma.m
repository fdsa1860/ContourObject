function [feat, ind] = structureBowCodeFeatHHSigma(img, centers, alpha, cells)
% Input:
% img: structure, all information in one image
% centers: 1 by K cell, cluster centers
% alpha: the weight of order in distance metric
% cells: cells divided to represent structure information of each image
% Output:
% feat: bag of words representation

if nargin < 3
    alpha = 0;
end

nCont = length(img.contour);
for i = 1:nCont
    contour = img.contour(i);
    nSeg = length(contour.seg);
    for j = 1:nSeg
        H = mexHankel(contour.seg(j).vel');
        HH = (H * H') / norm (H * H', 'fro');
        contour.seg(j).H = H;
        contour.seg(j).HH = HH;
    end
    D = dynamicDistanceSigmaCross(contour.seg, centers, alpha);
    [val,ind] = min(D, [], 2);
    contour.code = ind;
    img.contour(i) = contour;
end



end