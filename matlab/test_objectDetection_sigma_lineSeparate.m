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
tic
[dscA_all, seg_all, imgSize_all] = img2dscaAll(imgList, opt, false, true);
toc
% save(sprintf('dscASeg_%s_raw_20141005', opt), 'dscA_all', 'seg_all', 'imgSize_all', 'labels');
% load(sprintf('../expData/dscASeg_%s_raw_20141005', opt));

%% filter the short curves
[dscA_all, seg_all, dscA_ind] = filterWithFixedLengthAll(dscA_all, seg_all, 2*hankel_size);

%% slide window crop contours
[dscA_all, seg_all, points_all] = slideWindowChopContourAll(dscA_all, seg_all, 2*hankel_size, true);
% save(sprintf('dscASeg_%s_sw_20141005', opt), 'dscA_all', 'seg_all', 'points_all');
% load(sprintf('../expData/dscASeg_%s_sw_20141005', opt));

%% line detection
isLine_all = dscaLineDetectAll(dscA_all);

%% separate lines
[dscA_line_all, dscA_notLine_all, seg_line_all, seg_notLine_all, points_line_all, points_notLine_all] = separateLine(dscA_all, seg_all, points_all, isLine_all, true);

%% build hankel matrix
[dscA_notLine_all_H, dscA_notLine_all_HH] = buildHankelAll(dscA_notLine_all, hankel_size, 1, true);
% save(sprintf('HH_dscA_notLine_%s_20141005', opt), 'dscA_notLine_all_H', 'dscA_notLine_all_HH');
% load(sprintf('../expData/HH_dscA_notLine_%s_20141005', opt));

%% normalized singular value estimation
dscA_notLine_all_sigma = sigmaEstAll(dscA_notLine_all_H, []);
% save(sprintf('sigma_dscA_notLine_%s_20141005', opt), 'dscA_notLine_all_sigma');
% load(sprintf('../expData/sigma_dscA_notLine_%s_20141005', opt));

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
% save ped_dscA_notLine_centers_a001_20141005 centers centers_sigma centers_H centers_HH sD centerInd sLabel;
load ../expData/ped_dscA_notLine_centers_a001_20141005

%% bow representation
% featNotLine = bowFeatHHSigmaAll(dscA_notLine_all_HH, centers_HH, dscA_notLine_all_sigma, centers_sigma, alpha);
% % save feat_notLine_mytrain_sigma_a001_20141002 featNotLine labels;
% % load ../expData/feat_notLine_mytrain_sigma_a001_20141002

%% estimate line slope
slope_all = slopeEstAll(seg_line_all);

% %% line feature
nBins = 9;
% featLine = lineFeatAll(slope_all, nBins);
% % normalize
% featLine = l2Normalization(featLine);

%% structured line feature
block_all = cell(1, length(slope_all));
for i = 1:length(slope_all)
    block_all{i} = genBlock(imgSize_all(i,2), imgSize_all(i,1), 1, 4);
%     block_all{i} = genBlock(96, 160, 4, 5);
end
featLine = structureLineFeatAll(slope_all, nBins, points_line_all, block_all);
% save(sprintf('featLine_%s_20141005', opt), 'featLine');
% load(sprintf('../expData/featLine_%s_20141005', opt));
featLine = l2Normalization(featLine);

%% structured non-line feature
featNotLine = structuredBowFeatHHSigmaAll(dscA_notLine_all_HH, centers_HH, dscA_notLine_all_sigma, centers_sigma, alpha, points_notLine_all, block_all);
% save(sprintf('featNotLine_%s_a001_20141005', opt), 'featNotLine');
% load(sprintf('../expData/featNotLine_%s_a001_20141005', opt));
featNotLine = l2Normalization(featNotLine);

%% concatenate line feature and not-line feature
% feat = [featNotLine; featLine];
% feat = l2Normalization(feat);
% feat = featNotLine;
feat = featLine;


%% display

%% svm classification to test how hard the data is to classify
% load feature data
load ../expData/featLine_mytrain_20141005;
% featLine = powerNormalization(featLine);
featLine = l2Normalization(featLine);
load ../expData/featNotLine_mytrain_a001_20141005;
% featNotLine = powerNormalization(featNotLine);
featNotLine = l2Normalization(featNotLine);
feat = [featNotLine; featLine];
% feat = featNotLine;
% feat = featLine;
% save feat_mytrain_l2Norm_a001_20141005 feat labels;
% load ../expData/feat_mytrain_l2Norm_a001_20141005
X_train1 = feat;
% y_train1 = labels;

load ../expData/featLine_mytest_20141005;
% featLine = powerNormalization(featLine);
featLine = l2Normalization(featLine);
load ../expData/featNotLine_mytest_a001_20141005;
% featNotLine = powerNormalization(featNotLine);
featNotLine = l2Normalization(featNotLine);
feat = [featNotLine; featLine];
% feat = featNotLine;
% feat = featLine;
% save feat_mytest_l2Norm_a001_20141005 feat labels;
% load ../expData/feat_mytest_l2Norm_a001_20141002
X_test1 = feat;
% y_test1 = labels;

load ../expData/hog_train_20141006;
% X_train = powerNormalization(X_train);
% X_train = l2Normalization(X_train);
load ../expData/hog_test_20141006;
% X_test = powerNormalization(X_test);
% X_test = l2Normalization(X_test);
% X_train = [X_train;X_train1];
% X_test = [X_test;X_test1];

model = svmtrain(X_train, y_train, 'kernel_function', 'rbf');
pred = svmclassify(model, X_test');
accuracy = nnz(pred == y_test') / length(y_test);
fprintf('\naccuracy is %f\n',mean(accuracy));
% svmClassify(X_train, y_train);
% svmClassify(X_test, y_test);