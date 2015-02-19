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
    seg = slideWindowContour2Seg(contour(5), opt.segLength);
    seg = addHH(seg);
    seg = sigmaEst(seg);
    seg_train{i} = seg;
end

index = 1:length(seg);
label = zeros(1, length(seg));
X = zeros(2*(opt.segLength-4), length(seg));
for i = 1:length(seg)
    tmp = seg(i).vel';
    X(:, i) = tmp(:);
end
FF = zeros(4*(opt.segLength-4),10);

epsilon = 1e-1; fix = 1; tol = 1e-3; step = 1;
for iter = 1:10
    if isempty(X), break; end
    [F,F_i,T] = call_ssrrr_lp(X,epsilon,fix,tol,step);
    % ind = find(abs(F'*X) < epsilon);
    FF(:,iter) = F;
    ind = find(max(abs(reshape(F,size(F,1)/2,2)'*X))<=epsilon);
    label(index(ind)) = iter;
    X(:,ind) = [];
    index(ind) = [];
    fprintf('iter %d...\n',iter);
end

color = hsv(10);
plot(contour(5).points(:,2), contour(5).points(:,1),'.');hold on;
set(gca,'YDir','reverse');
for j = 1:10
    ind = find(label==j);
    for i=1:length(ind)
        plot(seg(ind(i)).loc(1), seg(ind(i)).loc(2),'.','MarkerEdgeColor',color(j,:));
    end
end
hold off;


%% show correspondence map
map(1:length(seg)) = struct('pts',[0 0], 'label', 0);
[~,file,~] = fileparts(trainFileNameList{1});
I = imread(sprintf(fullfile(dataDir,'images','train','%s.jpg'), file));
hgt = size(I, 1);
wid = size(I, 2);
count = 1;
for j = 1:length(label)
    map(count).pts = round(seg(j).loc);
    map(count).label = label(j);
    count = count + 1;
end
    
% show image
color = hsv(length(unique(label))-1);
I = zeros([hgt, wid, 3]);
for j = 1:length(map)
    if map(j).label==0, continue; end
    x = max(1, floor(map(j).pts(1)));
    y = max(1, floor(map(j).pts(2)));
    I(y, x, :) = color(map(j).label, :);
end
imshow(I);
colormap(color);
hbar = colorbar;
set(hbar, 'YTickLabel', [1:10]);

%%
order = 6;
epsilon = 0.3;
X3 = zeros(length(seg), 2);
for i = 1:length(seg)
    X3(i, :) = seg(i).vel(1,:);
end
[x label] = indep_dyn_switch_detect1(X3,inf,epsilon,order);
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

