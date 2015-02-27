
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
opt.hankel_size = 10;
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
% seg_train = cell(1, nTrain);
% for i = 1:nTrain
% % for i = 1
%     t = importdata(trainFileNameList{i});
% %     bw = t{opt.subjectNum}.Boundaries; cont = extractContBW(single(bw));
%     R = t{opt.subjectNum}.Segmentation; cont = extractContFromRegion(R);
%     contour = sampleAlongCurve(cont, opt.sampleMode, opt.sampleLen);
%     contour = filterContourWithFixedLength(contour, opt.segLength);
%     contour = filterContourWithLPF(contour);
% %     seg = slideWindowContour2Seg(contour, opt.segLength);
%     seg = contour2segModelSwitch(contour, opt);
%     seg = addHH(seg, opt.hankel_size);
%     seg = sigmaEst(seg);
%     seg_train{i} = seg;
% end
load ../expData/seg_train_20150221
for i = 1:length(seg_train)
    seg_train{i} = addHH(seg_train{i}, opt.hankel_size);
    seg_train{i} = sigmaEst(seg_train{i});
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
load ../expData/bsds_sD_h10_HtH_a0_20150225;
% load ../expData/bsds_sD_h10_HxytHxy_a0_20150225;
% load ../expData/bsds_sD_h10_a0_20150221
% tic;
[centers, sLabel, sD, W] = nCutContourHHSigma(segPool(1:10000), nc, opt.alpha, sD, 1e-4, 1);
% [centers, sLabel, sD, W] = nCutContourHHSigma(segPool(1:10000), nc, opt.alpha);
% toc
% save bsds_sD_a0_20150114 sD;
% save bsds_centers_w100_a0_sig001_20150114 centers sLabel;
load ../expData/bsds_centers_w10_h10_a0_sig1e-5_o1_20150225

%% show correspondence map
% seg_test = cell(1, nTest);
% for i = 1:nTest
for i = 1:nTrain
% for i = 1
% %     t = importdata(testFileNameList{i});
%     t = importdata(trainFileNameList{i});
% %     bw = t{opt.subjectNum}.Boundaries; cont = extractContBW(single(bw));
%     R = t{opt.subjectNum}.Segmentation; cont = extractContFromRegion(R);
%     contour = sampleAlongCurve(cont, opt.sampleMode, opt.sampleLen);
%     contour = filterContourWithFixedLength(contour, opt.segLength);
% %     contour = filterContourWithLPF(contour);
%     seg = slideWindowContour2Seg(contour(5), opt.segLength);
%     seg = addHH(seg);
%     seg = sigmaEst(seg);
%     seg_test{i} = seg;
    seg = seg_train{i};

    clear map;
    map(1:length(seg)) = struct('pts',[0 0], 'label', 0);
%     [~,file,~] = fileparts(testFileNameList{i});
    [~,file,~] = fileparts(trainFileNameList{i});
%     I = imread(sprintf(fullfile(dataDir,'images','test','%s.jpg'), file));
    I = imread(sprintf(fullfile(dataDir,'images','train','%s.jpg'), file));
    hgt = size(I, 1);
    wid = size(I, 2);
    D = dynamicDistanceSigmaCross(seg, centers, opt.alpha);
    [val,ind] = min(D, [], 2);
    count = 1;
    for j = 1:length(ind)
        for k = 1:size(seg(j).points, 1)
            map(count).pts = [seg(j).points(k,2) seg(j).points(k,1)];
            map(count).label = ind(j);
            count = count + 1;
        end
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

%%
order = 6;
epsilon = 0.3;
X = zeros(length(seg), 2);
for i = 1:length(seg)
    X(i, :) = seg(i).vel(1,:);
end
[x, label] = indep_dyn_switch_detect1(X,inf,epsilon,order);
label = [zeros(1,order) label];

uLabel = unique(label);
nL = length(uLabel);
color = hsv(nL);
figure;plot(contour(5).points(:,2), contour(5).points(:,1),'.');hold on;
set(gca,'YDir','reverse');
for j = 1:nL
    ind = find(label==j);
    for i=1:length(ind)
        plot(seg(ind(i)).loc(1), seg(ind(i)).loc(2),'.','MarkerEdgeColor',color(j,:));
    end
end
hold off;

%%
hL = [];
curLabel = label(1);
count = 0;
for i=1:length(label)
    if label(i)==curLabel
        count = count + 1;
        continue;
    else
        hL = [hL count];
        count = 1;
        curLabel = label(i);
    end
end
hL = [hL count];
hist(hL)