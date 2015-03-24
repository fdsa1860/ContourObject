
% test_MPEG7
% get contours from training data, do clustering, then label the test
% contours, output label maps

%% set up environment
clc;clear;close all;
addpath(genpath('../3rdParty'));
addpath(genpath('../matlab'));
addpath(genpath('../mex'));

dataDir = '~/research/data/MPEG7';

% parameters
opt.hankel_size = 7;
opt.sampleMode = 1;
opt.sampleLen = 1;
opt.minLen = 2 * opt.hankel_size + 2;
opt.segLength = 2 * opt.hankel_size + 1;
opt.alpha = 0;
opt.draw = false;
opt.verbose = true;
% opt.metric = 'HHt';
opt.metric = 'HtH';

%% get file name list
files = dir(fullfile(dataDir,'*.gif'));
n = length(files);
fileNameList = cell(1, n);
for i = 1:n
    fileNameList{i} = fullfile(dataDir,files(i).name);
end

%%
nTrain = 600;
seg_train = cell(1, nTrain);
for i = 1:nTrain
% for i = 1
    [~,fname,ext] = fileparts(fileNameList{i});
    I = imread(fileNameList{i});
    R = I;
    cont = extractContFromRegion(R);
    contour = sampleAlongCurve(cont, opt.sampleMode, opt.sampleLen);
    contour = filterContourWithFixedLength(contour, opt.segLength);
    contour = filterContourWithLPF(contour);
    seg = slideWindowContour2Seg(contour, opt.segLength);
    seg = addHH(seg, opt.hankel_size+1, opt.metric);
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
%% patition the pool
% L = zeros(1, length(segPool));
% for i = 1:length(segPool)
%     L(i) = size(segPool(i).points, 1);
% end
% ind{1} = find(L<=50); ind{2} = find(L>50 & L<=100); ind{3} = find(L>100);
% load ../expData/bsds_sD_h10_a0_c3_20150221;
% [centers1, sLabel1, sD{1}] = nCutContourHHSigma(segPool(ind{1}), nc, opt.alpha);
% [centers2, sLabel2, sD{2}] = nCutContourHHSigma(segPool(ind{2}), nc, opt.alpha);
% [centers3, sLabel3, sD{3}] = nCutContourHHSigma(segPool(ind{3}), nc, opt.alpha);
% centers = [centers1 centers2 centers3];
% load ../expData/bsds_centers_w30_h10_a0_sig001_c3_20150224

%% computer cluster centers
nc = 10;
% load ../expData/mpeg7_sD_h10_a0_HHt_20150322;
load ../expData/mpeg7_sD_h7_a0_HHt_20150323;
% load ../expData/mpeg7_sD_h7_a0_HtH_20150323;
tic;
[centers, sLabel, sD, W] = nCutContourHHSigma(segPool(1:10000), nc, opt.alpha, sD, 1e-3, 1);
% [centers, sLabel, sD, W] = nCutContourHHSigma(segPool(1:10000), nc, opt.alpha);
toc
% save mpeg7_sD_h10_a0_HtH_20150305 sD;
% save mpeg7_centers_w30_h10_a0_s5_o1_HtH_20150305 centers sLabel;
load ../expData/mpeg7_centers_w30_h10_a0_s5_o1_HtH_20150305

