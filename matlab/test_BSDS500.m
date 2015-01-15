% test_BSDS500
% get contours from training data, do clustering, then label the test
% contours, output label maps

%% set up environment
clc;clear;close all;
addpath(genpath('../3rdParty'));
addpath(genpath('../matlab'));
addpath(genpath('../mex'));

dataDir = '~/research/data/BSR/BSDS500/data';

% parameters
opt.hankel_size = 4;
opt.sampleMode = 1;
opt.sampleLen = 1;
opt.minLen = 2 * opt.hankel_size + 2;
opt.segLength = 2 * opt.hankel_size + 1;
opt.subjectNum = 1;
opt.alpha = 0;
opt.draw = false;
opt.verbose = true;

% opt = 'mytrain';
% opt = 'mytest';

%% get file name list
files = dir(fullfile(dataDir,'groundTruth','train','*.mat'));
nTrain = length(files);
trainFileNameList = cell(1, nTrain);
for i = 1:nTrain
    trainFileNameList{i} = fullfile(dataDir,'groundTruth','train',files(i).name);
end

%%
seg_all = cell(1, nTrain);
for i = 1:nTrain
    t = importdata(trainFileNameList{i});
    bw = t{opt.subjectNum}.Boundaries;
    cont = extractContBW(single(bw));
    contour = sampleAlongCurve(cont, opt.sampleMode, opt.sampleLen);
    contour = filterContourWithFixedLength(contour, opt.segLength);
    seg = slideWindowContour2Seg(contour, opt.segLength);
    seg = addHH(seg);
    seg = sigmaEst(seg);
    seg_all{i} = seg;
end

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
% load ../expData/ped_sD_a0_notClean_20141117;
% tic;
% [centers, sLabel, sD] = nCutContourHHSigma(segPool(1:10000), nc, opt.alpha);
% toc
% save bsds_sD_a0_20150114 sD;
% save bsds_centers_w100_a0_sig001_20150114 centers sLabel;
load ../expData/bsds_centers_w100_a0_sig001_20150114

1