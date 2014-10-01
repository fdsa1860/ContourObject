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
% [dscA_all, seg_all, dscA_ind] = filterWithFixedLengthAll(dscA_all, seg_all, 2*hankel_size);
% save dscASeg_mytrain_raw_20140926 dscA_all seg_all;
load ../expData/dscASeg_mytrain_raw_20140926

%% slide window crop contours
[dscA_all] = slideWindowChopContourAll(dscA_all, 2*hankel_size);

%% line detection
isLine_all = dscaLineDetectAll(dscA_all);
% save isLine_mytrain_20140926 isLine_all;
% load ../expData/isLine_mytrain_20140926;

%% build hankel matrix
[dscA_all_H, dscA_all_HH] = buildHankelAll(dscA_all, hankel_size, 1);
% load ../expData/HH_mytrain_20140926;

%% normalized singular value estimation
dscA_all_sigma = sigmaEstAll(dscA_all_H, isLine_all, true);
% save sigma_dscA_mytrain_20140930 dscA_all_sigma
% load ../expData/sigma_dscA_mytrain_20140930

%% pooling
% sampleNum = 10000;
% poolMaxSize = 50000;
% [dscAPool, dscAPoolOrder, dscAPoolSigma, dscAPoolH, dscAPoolHH] = pooling(dscA_all, [], dscA_all_sigma, dscA_all_H, dscA_all_HH, sampleNum, poolMaxSize);
% save dscAPool_20140930 dscAPool dscAPoolOrder dscAPoolSigma dscAPoolH dscAPoolHH;
% load ../expData/dscAPool_20140930;

%% computer cluster centers
% nc = 10;
% tic;
% [sLabel, centers, centers_sigma, centers_H, centers_HH, sD, centerInd] = nCutContourHHSigma(dscAPool(1:10000), dscAPoolSigma(:, 1:10000), dscAPoolH(1:10000), dscAPoolHH(1:10000), nc, alpha);
% toc
% save ped_dscA_centers_a001_20141001 centers centers_sigma centers_H centers_HH sD centerInd sLabel;
load ../expData/ped_dscA_centers_a001_20141001

%% bow representation
feat = bowFeatHHSigmaAll(dscA_all_HH, centers_HH, dscA_all_sigma, centers_sigma, alpha);
% save feat_mytrain_sigma_a001_20140930 feat labels;
% load ../expData/feat_mytrain_sigma_a001_20140930

%% display

%% svm classification to test how hard the data is to classify
svmClassify(feat, labels);
