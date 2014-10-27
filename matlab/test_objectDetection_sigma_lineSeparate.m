% object detection

%% set up environment
clc;clear;close all;
addpath(genpath('../3rdParty'));
addpath(genpath('../matlab'));

hankel_size = 4;
alpha = 0;

opt = 'mytrain';
% opt = 'mytest';

%% load data
posDir = sprintf('../../../data/INRIAPerson/%s/pos/', opt);
negDir = sprintf('../../../data/INRIAPerson/%s/neg/', opt);
[imgList, labels] = loadImgList(posDir, negDir);

%% compute contours, then features
% tic
% [dscA_all, seg_all, imgSize_all] = img2dscaAll(imgList, opt, false, true);
% toc
% save(sprintf('dscaSeg_%s_20141005', opt), 'dscA_all', 'seg_all', 'imgSize_all', 'labels');
load(sprintf('../expData/dscASeg_%s_20141012', opt));

%% filter the short curves
[dscA_all, seg_all, dscA_ind] = filterWithFixedLengthAll(dscA_all, seg_all, 2*hankel_size);

%% slide window crop contours
[dscA_all, seg_all, points_all] = slideWindowChopContourAll(dscA_all, seg_all, 2*hankel_size, true);
% save(sprintf('dscASeg_%s_sw_20141005', opt), 'dscA_all', 'seg_all', 'points_all');
% load(sprintf('../expData/dscASeg_%s_sw_20141005', opt));

%% line detection
isLine_all = dscaLineDetectAll(dscA_all);

%% separate lines
[dscA_line_all, dscA_notLine_all, seg_line_all, seg_notLine_all, points_line_all, points_notLine_all] = separateLine(isLine_all, dscA_all, seg_all, points_all, true);
% [dscA_line_all, dscA_notLine_all, seg_line_all, seg_notLine_all, points_line_all, points_notLine_all] = separateLine(isLine_all, dscA_all, seg_all, [], true);

%% build hankel matrix
dscA_notLine_all_data = buildHankelAll(dscA_notLine_all, hankel_size, 1, true);
% save(sprintf('HH_dscA_notLine_%s_20141005', opt), 'dscA_notLine_all_H', 'dscA_notLine_all_HH');
% load(sprintf('../expData/HH_dscA_notLine_%s_20141005', opt));

%% normalized singular value estimation
dscA_notLine_all_data = sigmaEstAll(dscA_notLine_all_data);
% save(sprintf('sigma_dscA_notLine_%s_20141005', opt), 'dscA_notLine_all_sigma');
% load(sprintf('../expData/sigma_dscA_notLine_%s_20141005', opt));

%% pooling
poolMaxSize = 50000;
dscANotLinePool = pooling(dscA_notLine_all_data, poolMaxSize);
% save dscANotLinePool_20141005 dscANotLinePool dscANotLinePoolOrder dscANotLinePoolSigma dscANotLinePoolH dscANotLinePoolHH;
% load ../expData/dscANotLinePool_20141005;

%% computer cluster centers
nc = 10;
% load ../expData/ped_dscA_notLine_sD_a0_20141012
% tic;
% [centers, sLabel, sD] = nCutContourHHSigma(dscANotLinePool(1:10000), nc, alpha, sD);
% toc
% save ped_dscA_notLine_sD_a0_20141012 sD;
% save ped_dscA_notLine_centers_w10_a0_h4_sig001_20141023 centers sLabel;
load ../expData/ped_dscA_notLine_centers_w10_a0_h4_sig001_20141023
centers(10) = [];

%% estimate line slope
slope_all = slopeEstAll(seg_line_all);

%% structured line feature
block_all = cell(1, length(slope_all));
for i = 1:length(slope_all)
    block_all{i} = genBlock([1 1 imgSize_all(i,2) imgSize_all(i,1)], 4, 16);
%     block_all{i} = genBlock(96, 160, 4, 5);
end

% structured line feature
nBins = 9;
featLine = structureLineFeatAll(slope_all, nBins, points_line_all, block_all);
% save(sprintf('featLine_%s_h4_wd4ht16_20141012', opt), 'featLine', 'labels');
% load(sprintf('../expData/featLine_%s_20141005', opt));
featLine = l2Normalization(featLine);

% structured non-line feature
featNotLine = structureBowFeatHHSigmaAll(dscA_notLine_all_data, centers, alpha, points_notLine_all, block_all);
% save(sprintf('featNotLine_%s_c10_a0_h4_wd4ht16_20141012', opt), 'featNotLine', 'labels');
% load(sprintf('../expData/featNotLine_%s_a001_20141005', opt));
featNotLine = l2Normalization(featNotLine);

%% length 2 segment feature
load(sprintf('../expData/dscASeg_%s_20141012', 'mytrain'));
[dscA_all, seg_all, dscA_ind] = filterWithFixedLengthAll(dscA_all, seg_all, 2*hankel_size);
tic
% parameters
opt.hankel_size = 4;
opt.alpha = 0;
opt.hankel_mode = 1;
opt.nBins = 9;
opt.minLen = 2 * opt.hankel_size + 2;
opt.draw = false;

img.opt = opt;
img.centers = centers;
numImg = length(imgList);
feat2 = zeros(171, numImg);
for i = 1:numImg
    fprintf('Processing Image %d/%d ... \n', i, numImg);
    img.imgFile = imgList{i};
    
    for j = 1:length(dscA_all{i})
        img.cont(j).dsca = dscA_all{i}{j};
        img.cont(j).points = seg_all{i}{j};
    end
    
    [contCode, img] = img2contourCode(img);
    feat2(:,i) = contourCode2feat(img, 2);
end
fprintf('finish!\n')
feat2 = l2Normalization(feat2);
toc
save feat2_c10_a0_h4_20141026 feat2;
% load feat2_c10_a0_h4_20141026

%% length 3 segment feature
load(sprintf('../expData/dscASeg_%s_20141012', 'mytrain'));
[dscA_all, seg_all, dscA_ind] = filterWithFixedLengthAll(dscA_all, seg_all, 2*hankel_size);
tic
% parameters
opt.hankel_size = 4;
opt.alpha = 0;
opt.hankel_mode = 1;
opt.nBins = 9;
opt.minLen = 2 * opt.hankel_size + 2;
opt.draw = false;

img.opt = opt;
img.centers = centers;
numImg = length(imgList);
feat3 = zeros(1140, numImg);
for i = 1:numImg
    fprintf('Processing Image %d/%d ... \n', i, numImg);
    img.imgFile = imgList{i};
    
    for j = 1:length(dscA_all{i})
        img.cont(j).dsca = dscA_all{i}{j};
        img.cont(j).points = seg_all{i}{j};
    end
    
    [contCode, img] = img2contourCode(img);
    feat3(:,i) = contourCode2feat(img, 3);
end
fprintf('finish!\n')
feat3 = l2Normalization(feat3);
toc
save feat3_c10_a0_h4_20141026 feat3;
% load feat2_c10_a0_h4_20141026

% concatenate line feature and not-line feature
feat = [featNotLine; featLine; feat2; feat3];
% feat = l2Normalization(feat);
% feat = featNotLine;
% feat = featLine;

%% svm classification to test how hard the data is to classify
% load feature data
% load ../expData/featLine_mytrain_h4_wd4ht16_20141012;
% featLine = powerNormalization(featLine);
% featLine = l2Normalization(featLine);
% load ../expData/featNotLine_mytrain_c10_a0_h4_wd4ht16_20141012;
% featNotLine = powerNormalization(featNotLine);
% featNotLine = l2Normalization(featNotLine);
% feat = [featNotLine; featLine];
% feat = featNotLine;
% feat = featLine;
% save feat_mytrain_l2Norm_a001_20141005 feat labels;
% load ../expData/feat_mytrain_l2Norm_a001_20141005
X_train = feat;
y_train = labels;

% load ../expData/featLine_mytest_20141005;
% % featLine = powerNormalization(featLine);
% featLine = l2Normalization(featLine);
% load ../expData/featNotLine_mytest_a001_20141005;
% % featNotLine = powerNormalization(featNotLine);
% featNotLine = l2Normalization(featNotLine);
% feat = [featNotLine; featLine];
% % feat = featNotLine;
% % feat = featLine;
% % save feat_mytest_l2Norm_a001_20141005 feat labels;
% % load ../expData/feat_mytest_l2Norm_a001_20141002
% X_test1 = feat;
% y_test = labels;

% load ../expData/hog_train_20141006;
% % X_train = powerNormalization(X_train);
% % X_train = l2Normalization(X_train);
% load ../expData/hog_test_20141006;
% % X_test = powerNormalization(X_test);
% % X_test = l2Normalization(X_test);
% X_train = [X_train];
% X_test = [X_test;X_test1];

tic;[accMat, libsvmModel] = libsvmClassify(X_train, y_train);toc
% tic;liblinearClassify(X_train, y_train, X_test, y_test);toc

