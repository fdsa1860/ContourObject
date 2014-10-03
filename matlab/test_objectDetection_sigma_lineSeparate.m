% object detection

%% set up environment
clc;clear;close all;
addpath(genpath('../3rdParty'));
addpath(genpath('../matlab'));

hankel_size = 4;
alpha = 0.01;

opt = 'mytrain';
% opt = 'mytest';

%% load data
posDir = sprintf('../../../data/INRIAPerson/%s/pos/', opt);
negDir = sprintf('../../../data/INRIAPerson/%s/neg/', opt);
[imgList, labels] = loadImgList(posDir, negDir);

%% compute contours, then features
% tic
% [dscA_all, seg_all] = img2dscaAll(imgList, true);
% toc
% save dscASeg_mytrain_raw_20140926 dscA_all seg_all;
load ../expData/dscASeg_mytrain_raw_20140926
% save dscASeg_mytest_raw_20140926 dscA_all seg_all;
% load ../expData/dscA_mytest_raw_20140926

%% filter the short curves
[dscA_all, seg_all, dscA_ind] = filterWithFixedLengthAll(dscA_all, seg_all, 2*hankel_size);

%% slide window crop contours
% [dscA_all, seg_all, points_all] = slideWindowChopContourAll(dscA_all, seg_all, 2*hankel_size, true);
% save dscASeg_mytrain_sw_20141002 dscA_all seg_all points_all
load ../expData/dscASeg_mytrain_sw_20141002;

%% line detection
isLine_all = dscaLineDetectAll(dscA_all);

%% separate lines
[dscA_line_all, dscA_notLine_all, seg_line_all, seg_notLine_all, points_line_all, points_notLine_all] = separateLine(dscA_all, seg_all, points_all, isLine_all, true);

%% build hankel matrix
[dscA_notLine_all_H, dscA_notLine_all_HH] = buildHankelAll(dscA_notLine_all, hankel_size, 1, true);
% save HH_dscA_notLine_mytrain_20141002 dscA_notLine_all_H dscA_notLine_all_HH
% load ../expData/HH_dscA_notLine_mytrain_20141002;

%% normalized singular value estimation
dscA_notLine_all_sigma = sigmaEstAll(dscA_notLine_all_H, []);
% save sigma_dscA_notLine_mytrain_20141002 dscA_notLine_all_sigma
% load ../expData/sigma_dscA_notLine_mytrain_20141002

%% pooling
% sampleNum = 10000;
% poolMaxSize = 50000;
% [dscANotLinePool, dscANotLinePoolOrder, dscANotLinePoolSigma, dscANotLinePoolH, dscANotLinePoolHH] = pooling(dscA_notLine_all, [], dscA_notLine_all_sigma, dscA_notLine_all_H, dscA_notLine_all_HH, sampleNum, poolMaxSize);
% save dscANotLinePool_20141002 dscANotLinePool dscANotLinePoolOrder dscANotLinePoolSigma dscANotLinePoolH dscANotLinePoolHH;
% load ../expData/dscANotLinePool_20141002;

%% computer cluster centers
nc = 10;
% load ../expData/ped_dscA_notLine_centers_a001_20141002
% tic;
% [sLabel, centers, centers_sigma, centers_H, centers_HH, sD, centerInd] = nCutContourHHSigma(dscANotLinePool(1:10000), dscANotLinePoolSigma(:, 1:10000), dscANotLinePoolH(1:10000), dscANotLinePoolHH(1:10000), nc, alpha);
% toc
% save ped_dscA_notLine_centers_a001_20141002 centers centers_sigma centers_H centers_HH sD centerInd sLabel;
load ../expData/ped_dscA_notLine_centers_a001_20141002

%% bow representation
featNotLine = bowFeatHHSigmaAll(dscA_notLine_all_HH, centers_HH, dscA_notLine_all_sigma, centers_sigma, alpha);
% save feat_notLine_mytrain_sigma_a001_20141002 featNotLine labels;
% load ../expData/feat_notLine_mytrain_sigma_a001_20141002

%% estimate line slope
slope_all = slopeEstAll(seg_line_all);

%% line feature
nBins = 9;
featLine = lineFeatAll(slope_all, nBins);
% normalize
featLine = l2Normalization(featLine);

%% structured line feature
wid = 96; hgt = 160;
block_all = cell(1, length(slope_all));
for i = 1:length(slope_all)
    block_all{i} = genBlock(wid, hgt, 1, 4);
end
featLine = structureLineFeatAll(slope_all, nBins, points_line_all, block_all);
featLine = l2Normalization(featLine);

%% structured non-line feature
featNotLine = structuredBowFeatHHSigmaAll(dscA_notLine_all_HH, centers_HH, dscA_notLine_all_sigma, centers_sigma, alpha, points_notLine_all, block_all);
featNotLine = l2Normalization(featNotLine);

%% concatenate line feature and not-line feature
feat = [featNotLine; featLine];
% feat = l2Normalization(feat);
% feat = featNotLine;
% feat = featLine;

%% display

%% svm classification to test how hard the data is to classify
fprintf('classifying ...\n');
svmClassify(feat, labels);
