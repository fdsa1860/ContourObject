% object detection

%% set up environment
clc;clear;close all;
addpath(genpath('../3rdParty'));
addpath(genpath('../matlab'));

hankel_size = 4;


%% load data

% load positive images to posList
posDir = '../../../data/INRIAPerson/mytrain/pos/';
% posList = importdata('/Users/xikang/Documents/data/INRIAPerson/train_64x128_H96/pos.lst');
pfileList = dir(fullfile(posDir,'*.png'));
np = length(pfileList);
posList = cell(1, np);
for i = 1:np
    posList{i} = [posDir pfileList(i).name];
end
% label
posLabels = ones(1, np);

% load negative images to negList
negDir = '../../../data/INRIAPerson/mytrain/neg/';
nfileList = dir(fullfile(negDir,'*.png'));
nn = length(nfileList);
negList = cell(1, nn);
for i = 1:nn
    negList{i} = [negDir nfileList(i).name];
end
% label
negLabels = -ones(1, nn);

% merge fileList and label
imgList = [posList negList];
labels = [posLabels negLabels];
% imgList = [posList(1:100) negList(1:100)];
% labels = [posLabels(1:100) negLabels(1:100)];

%% load cluster centers
% load('../expData/clusterCenters.mat');
% rng(0);
% sampleNum = 1000;
% contourPoolMaxSize = 10000;
% ri = randi(length(imgList), sampleNum, 1);
% contourPool = cell(1, contourPoolMaxSize);
% counter = 0;
% for i = 1:length(ri)
%     img = im2double(imread(imgList{ri(i)}));
%     dscA = img2dscA(img);
%     nd = length(dscA);
%     counterEnd = counter + nd;
%     if counterEnd > contourPoolMaxSize
%         break;
%     end
%     contourPool(counter+1:counterEnd) = dscA;
%     counter = counterEnd;
%     fprintf('Processing image %d ... \n', i);
% end
% fprintf('Process finished!\n');
% contourPool(counter+1:end) = [];
% % save contourPool_0918 contourPool;
% load('../expData/contourPool_0918.mat');
% [contourPool, sorder, sH, sHHp] = orderEst(contourPool, hankel_size);
% % save('contourPool_clean_0918', 'contourPool', 'sorder', 'sH', 'sHHp');
% % load('../expData/contourPool_clean_0918', 'contourPool', 'sorder', 'sH', 'sHHp');
% sD = dynamicDistance(sHHp, 1:length(sorder), sorder);
% sk = numel(unique(sorder));
% % % sk = 9;
% sLabel = Ncuts(sD, sk, sorder);
% centerInd = findCenters(sD,sLabel);
% centers = contourPool(centerInd);
% % save pedestrianCenters_20140918 centers;
load ../expData/pedestrianCenters_20140918

%% compute contours, then features
tic
nc = length(centers);
numImg = length(imgList);
feat = zeros(nc, numImg);
for i = 1:numImg
    img = im2double(imread(imgList{i}));
    dscA = img2dscA(img);
    [dscA, sorder, sH, sHHp] = orderEst(dscA, hankel_size);
    if isempty(dscA)
        feat(:,i) = zeros(nc,1);
    else
        feat(:,i) = bowFeat(dscA, centers);
    end
    fprintf('Processing image %d ... \n', i);
end
fprintf('Process finished!\n');
toc

% save feat_20140918 feat;
load feat_20140918
%% bow representation
% compute centers
% cntrInd = findCenters(sD, slabel);
% centers = dscA(cntrInd);
% save cluster centers

%% display

%% svm classification to test how hard the data is to classify

addpath(genpath('../3rdParty/liblinear-1.94/matlab'));

% ind = randperm(200);
% feat_perm = feat(:,ind);
% labels_perm = labels(ind);
% X_train = feat_perm(:,1:150);
% X_test = feat_perm(:,151:200);
% y_train = labels_perm(1:150);
% y_test = labels_perm(151:200);

K = 5;
ind = crossvalind('Kfold',length(labels),K);
accuracyCross = zeros(1, K);
for k = 1:K
    X_train = feat(:,ind~=k);
    X_test = feat(:,ind==k);
    y_train = labels(ind~=k);
    y_test = labels(ind==k);
    
    % Cind = -1:10;
    % C = 2.^Cind;
    C = 0.1;
    accuracyMat = zeros(1,length(C));
    for ci = 1:length(C)
        model = train(y_train',sparse(X_train'),sprintf('-s 2 -c %d',C(ci)));
        %         [predict_label, ~, prob_estimates] = predict(y_validate2', sparse(X2_validate'), model);
        %         accuracy(i) = nnz(predict_label==y_validate2')/length(y_validate2);
        [predict_label, ~, prob_estimates] = predict(y_test', sparse(X_test'), model);
        accuracy = nnz(predict_label==y_test')/length(y_test);
        svmModel = model;
        fprintf('\naccuracy is %f\n',mean(accuracy));
        accuracyMat(ci) = mean(accuracy);
    end
    accuracyCross(k) = accuracy;
end
rmpath(genpath('../3rdParty/liblinear-1.94/matlab'));