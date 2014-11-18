% test detection on INRIA pedestrian dataset

%% set up environment
clc;clear;close all;
addpath(genpath('../3rdParty'));
addpath(genpath('../matlab'));
addpath(genpath('../mex'));

% parameters
opt.hankel_size = 4;
opt.alpha = 0;
opt.hankel_mode = 1;
opt.nBins = 9;
opt.minLen = 2 * opt.hankel_size + 2;
opt.segLength = 2 * opt.hankel_size + 1;
opt.draw = false;
opt.verbose = true;
opt.localDir = '/Users/xikangzhang/research/code/ContourObject/expData/ped_contour_fast/contour_%s_%05d';
opt.segDir = '/Users/xikangzhang/research/code/ContourObject/expData/ped_seg_fast/seg_%s_h%02d_%05d';

opt.dataset = 'mytrain';
% opt = 'mytest';

%% load data
posDir = sprintf('../../../data/INRIAPerson/%s/pos/', opt.dataset);
negDir = sprintf('../../../data/INRIAPerson/%s/neg/', opt.dataset);
[imgList, labels] = loadImgList(posDir, negDir);

%% compute contours, then features
tic
% [dscA_all, seg_all, imgSize_all] = img2contAll(imgList, opt, false, true);
img_all = img2contour_all(imgList, labels, opt);
toc

%% crop sontours into segments
seg_all = imgContour2Seg_all(img_all, opt);

%% pooling
poolMaxSize = 50000;
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

%% computer cluster centers
nc = 100;
% load ../expData/ped_sD_a0_notClean_20141030;
% tic;
% [centers, sLabel, sD] = nCutContourHHSigma(segPool(1:10000), nc, opt.alpha);
% toc
% save ped_sD_a0_notClean_20141104 sD;
% save ped_centers_w100_a0_sig001_20141104 centers sLabel;
load ../expData/ped_centers_w100_a0_sig001_20141104

% load centers
% load ../expData/voc_dsca_notLine_centers_w10_a0_h4_20141016;
% img.centers = centers;
% centers = centers(1:50);

%% get feature
% ind = zeros(64, 1);
% for i = 1:64
%     ind(i) = 50*(i-1)+1;
% end
tic
% profile on;
numImg = length(img_all);
for i = 1:numImg
% for i = 1:1
    img = img_all{i};
    cells = genCells([1 1 img.width img.height], 4, 16);
    [feat, ind] = structureBowFeatHHSigma(img.seg, centers, opt.alpha, cells);
%     feat(ind,:) = 0;
    img.feat = [];
    img.feat = feat;
    img_all{i} = img;
end
% profile viewer
toc
% save img_all img_all
 


%% classify
numImg = length(img_all);
X_train = zeros(4*15*3*100, numImg);
for i = 1:numImg
    X_train(:,i) = img_all{i}.feat;
    y_train(i) = img_all{i}.label;
end
X_train = l2Normalization(X_train);
tic;[accMat, libsvmModel] = libsvmClassify(X_train, y_train);toc