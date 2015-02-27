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
opt.hankel_size = 7;
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
trainFiles = dir(fullfile(dataDir,'groundTruth','train','*.mat'));
nTrain = length(trainFiles);
trainFileNameList = cell(1, nTrain);
for i = 1:nTrain
    trainFileNameList{i} = fullfile(dataDir,'groundTruth','train',trainFiles(i).name);
end
testFiles = dir(fullfile(dataDir,'groundTruth','test','*.mat'));
nTest = length(testFiles);
testFileNameList = cell(1, nTest);
for i = 1:nTest
    testFileNameList{i} = fullfile(dataDir,'groundTruth','test',testFiles(i).name);
end

%%
seg_train = cell(1, nTrain);
for i = 1:nTrain
    t = importdata(trainFileNameList{i});
    bw = t{opt.subjectNum}.Boundaries;
    cont = extractContBW(single(bw));
    contour = sampleAlongCurve(cont, opt.sampleMode, opt.sampleLen);
    contour = filterContourWithFixedLength(contour, opt.segLength);
    seg = slideWindowContour2Seg(contour, opt.segLength);
    seg = addHH(seg);
    seg = sigmaEst(seg);
    seg_train{i} = seg;
end

%% pooling
poolMaxSize = 50000;
rng('default');
numImg = length(seg_train);
r = randperm(numImg);
counter = 1;
segPool = [];
for i = 1:numImg
    segPool = [segPool seg_train{r(i)}];
    counter = counter + length(seg_train{r(i)});
    if counter > poolMaxSize, break; end
end

%% computer cluster centers
% nc = 10;
% load ../expData/bsds_sD_h7_a0_20150114;
% tic;
% [centers, sLabel, sD] = nCutContourHHSigma(segPool(1:10000), nc, opt.alpha, sD);
% toc
% save bsds_sD_a0_20150114 sD;
% save bsds_centers_w100_a0_sig001_20150114 centers sLabel;
load ../expData/bsds_centers_w10_h7_a0_sig001_20150114

%% show correspondence map
seg_test = cell(1, nTest);
% for i = 1:nTest
for i = 1
    t = importdata(testFileNameList{i});
%     bw = t{opt.subjectNum}.Boundaries; cont = extractContBW(single(bw));
    R = t{opt.subjectNum}.Segmentation; cont = extractContFromRegion(R);
    contour = sampleAlongCurve(cont, opt.sampleMode, opt.sampleLen);
    contour = filterContourWithFixedLength(contour, opt.segLength);
%     contour = filterContourWithLPF(contour);
    seg = slideWindowContour2Seg(contour, opt.segLength);
    seg = addHH(seg);
    seg = sigmaEst(seg);
    seg_test{i} = seg;
    
    clear map;
    map(1:length(seg)) = struct('pts',[0 0], 'label', 0);
    [~,file,~] = fileparts(testFileNameList{i});
    I = imread(sprintf(fullfile(dataDir,'images','test','%s.jpg'), file));
    hgt = size(I, 1);
    wid = size(I, 2);
    cells.bbox = [1 1 wid hgt];
    cells.nr = 1;
    cells.nc = 1;
    cells.num = 1;
    [~, ind] = structureBowFeatHHSigma(seg, centers, opt.alpha, cells);
    count = 1;
    for j = 1:length(ind)
        map(count).pts = seg(j).loc;
        map(count).label = ind(j);
        count = count + 1;
    end
    
    % show image
    color = hsv(length(centers));
    I = zeros([hgt, wid, 3]);
    for j = 1:length(map)
        x = max(1, floor(map(j).pts(1)));
        y = max(1, floor(map(j).pts(2)));
        I(y, x, :) = color(map(j).label, :);
    end
    imshow(I);
    colormap(color);
    hbar = colorbar;
    % set(hbar, 'YTickLabel', [1:98]);
%     pause;
    keyboard;
end

1