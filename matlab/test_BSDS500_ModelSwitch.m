
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
opt.hankel_size = 5;
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
% for i = 1:nTrain
for i = 1
    t = importdata(trainFileNameList{i});
%     bw = t{opt.subjectNum}.Boundaries; cont = extractContBW(single(bw));
    R = t{opt.subjectNum}.Segmentation; cont = extractContFromRegion(R);
    contour = sampleAlongCurve(cont, opt.sampleMode, opt.sampleLen);
    contour = filterContourWithFixedLength(contour, opt.segLength);
    contour = filterContourWithLPF(contour);
%     seg = slideWindowContour2Seg(contour, opt.segLength);
    seg = contour2segModelSwitch(contour, opt);
    seg = addHH(seg);
    seg = sigmaEst(seg);
    seg_train{i} = seg;
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