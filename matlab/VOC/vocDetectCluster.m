% function [centers, sLabel, sD] = vocDetectCluster()

%% set up environment
% parameters
opt.hankel_size = 7;
opt.alpha = 0;
opt.hankel_mode = 1;
opt.nBins = 9;
opt.minLen = 2 * opt.hankel_size + 2;
opt.segLength = 2 * opt.hankel_size + 1;
opt.draw = false;
opt.verbose = true;
opt.localDir = '/Users/xikangzhang/research/code/ContourObject/expData/voc_contour/contour_%s_%05d';
opt.segDir = '/Users/xikangzhang/research/code/ContourObject/expData/voc_seg/seg_%s_h%02d_%05d';
opt.dataset = 'voc_train';
opt.imgDir = '/Users/xikangzhang/research/data/pascal/VOC2007/JPEGImages/%s.jpg';
opt.imgSetDir = '/Users/xikangzhang/research/data/pascal/VOC2007/ImageSets/Main/%s.txt';

%% load 'train' image set
ids = textread(sprintf(opt.imgSetDir,'train'),'%s');
imgList = cell(1, length(ids));
for i = 1:length(imgList)
    imgList{i} = sprintf(opt.imgDir, ids{i});
end
labels = ones(1, length(ids));

%% compute contours, then features
tic
img_all = img2contour_all(imgList, labels, opt);
toc

%% crop contours into segments
opt.hankel_size = 7;
opt.segLength = 2 * opt.hankel_size + 1;
seg_all = imgContour2Seg_all(img_all, opt);

%% pooling
poolMaxSize = 500000;
rng('default');
numImg = length(seg_all);
r = randperm(numImg);
counter = 1;
segPool = [];
for i = 1:numImg
    segPool = [segPool seg_all{r(i)}];
    counter = counter + length(seg_all{r(i)});
    if counter > poolMaxSize, break; end
end
segPool = segPool(randperm(length(segPool)));
segPool = segPool(1:30000);

%% computer cluster centers
nc = 100;
% load ../expData/ped_sD_a0_notClean_20141117;
% tic;
% [centers, sLabel, sD] = nCutContourHHSigma(segPool, nc, opt.alpha);
% toc
% save voc_sD_a0_20141205 sD;
% save voc_centers_w100_a0_sig001_20141205 centers sLabel;
% load ../expData/ped_centers_w100_a0_sig001_20141117

% load centers
load ../expData/voc_centers_w100_a0_sig001_20141205;
% img.centers = centers;
% centers = centers(1:50);




 
