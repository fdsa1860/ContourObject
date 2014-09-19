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


%% compute contours, then features
% tic
% numImg = length(imgList);
% dscA_all = cell(1, numImg);
% for i = 1:numImg
%     img = im2double(imread(imgList{i}));
%     dscA = img2dscA(img);
%     dscA_all{i} = dscA;
%     fprintf('Processing image %d ... \n', i);
% end
% fprintf('Process finished!\n');
% toc
% save dscA_all_raw_20140919 dscA_all;
% load ../expData/dscA_all_raw_20140919


%% order estimation
% numImg = length(dscA_all);
% dscA_all_clean = cell(numImg, 1);
% dscA_all_order = cell(numImg, 1);
% dscA_all_H = cell(numImg, 1);
% dscA_all_HH = cell(numImg, 1);
% for i = 1:numImg
%     [dscA_all_clean{i}, dscA_all_order{i}, dscA_all_H{i}, dscA_all_HH{i}] = orderEst(dscA_all{i}, hankel_size);
%     fprintf('Processing image %d ... \n', i);
% end
% fprintf('Process finished!\n');
% save dscA_all_clean_20140919 dscA_all_clean dscA_all_order dscA_all_H dscA_all_HH;
load ../expData/dscA_all_clean_20140919


%% computer cluster centers
% sampleNum = 1000;
% poolMaxSize = 10000;
% [contourPool, poolOrder, poolH, poolHH] = pooling(dscA_all_clean, dscA_all_order, dscA_all_H, dscA_all_HH, sampleNum, poolMaxSize);
% [sLabel, centers, centers_order, centers_H, centers_HH, sD, centerInd] = nCutContourHH(contourPool, poolOrder, poolH, poolHH);
% % save pedestrianCenters_20140919 centers centers_order centers_H centers_HH;
load ../expData/pedestrianCenters_20140919


%% bow representation
nc = length(centers);
numImg = length(dscA_all_clean);
feat = zeros(nc, numImg);
for i = 1:numImg
    if isempty(dscA_all_clean{i})
        feat(:,i) = zeros(nc,1);
    else
        feat(:,i) = bowFeatHH(dscA_all_HH{i}, centers_HH, dscA_all_order{i}, centers_order);
    end
end
% save feat_hOrder_20140919 feat;
% load ../expData/feat_hOrder_20140919


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