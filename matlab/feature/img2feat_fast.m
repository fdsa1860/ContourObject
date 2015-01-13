function feat = img2feat_fast(I, sbin)

persistent centers;

if isempty(centers)
    % load centers
    v = load('../expData/voc_centers_w100_a0_sig001_20141205.mat','centers');
    centers = v.centers;
end

% parameters
opt.hankel_size = 7;
opt.alpha = 0;
opt.hankel_mode = 1;
% opt.nBins = 9;
opt.minLen = 2 * opt.hankel_size + 2;

contour = img2contour_fast(I);
img.opt = opt;
img.width = size(I, 2);
img.height = size(I, 1);
img.contour = contour;
% img = imgAddSeg(img);
% img = imgAddHH(img);
% img = imgAddSigma(img);

segLength = 2 * opt.hankel_size + 1;
contour = filterContourWithFixedLength(contour, segLength);
seg = slideWindowContour2Seg(contour, segLength);
seg = addHH(seg);
seg = sigmaEst(seg);
img.seg = seg;

cells = genCells([1 1 img.width img.height], sbin);
[feat, ind] = structureBowFeatHHSigma(img.seg, centers, opt.alpha, cells);

end