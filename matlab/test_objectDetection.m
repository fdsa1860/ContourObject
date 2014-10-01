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

% load positive images to posList
posDir = sprintf('../../../data/INRIAPerson/%s/pos/',opt);

pfileList = dir(fullfile(posDir,'*.png'));
np = length(pfileList);
posList = cell(1, np);
for i = 1:np
    posList{i} = [posDir pfileList(i).name];
end
% label
posLabels = ones(1, np);

% load negative images to negList
negDir = sprintf('../../../data/INRIAPerson/%s/neg/', opt);
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
% seg_all = cell(1, numImg);
% % for i = 1:numImg
% for i = 1
%     img = im2double(imread(imgList{i}));
%     [dscA, seg] = img2dscA(img, true);
%     dscA_all{i} = dscA;
%     seg_all{i} = seg;
%     fprintf('Processing image %d ... \n', i);
% end
% fprintf('Process finished!\n');
% toc
% save dscASeg_mytrain_raw_20140926 dscA_all seg_all;
load ../expData/dscASeg_mytrain_raw_20140926
% save dscASeg_mytest_raw_20140926 dscA_all seg_all;
% load ../expData/dscA_mytest_raw_20140926

%% filter the short curves
[dscA_all, seg_all, dscA_ind] = filterWithFixedLengthAll(dscA_all, seg_all, 2*hankel_size);
% save dscASeg_mytrain_raw_20140926 dscA_all seg_all;
% load ../expData/dscASeg_mytrain_raw_20140926

%% slide window crop contours
[dscA_all] = slideWindowChopContourAll(dscA_all, 2*hankel_size);

%% line detection
isLine_all = dscaLineDetectAll(dscA_all);
% save isLine_mytrain_20140926 isLine_all;
% load ../expData/isLine_mytrain_20140926;

%% order estimation
% [dscA_all_order, dscA_all_clean] = orderEstAll(dscA_all, isLine_all, true);
% save dscA_mytrain_clean_20140930 dscA_all_order dscA_all_clean 
% load ../expData/dscA_mytrain_clean_20140930
% save dscA_mytest_clean_20140926 dscA_all_order dscA_all_clean;
% load ../expData/dscA_mytest_clean_20140924

% [seg_all_order, seg_all_clean] = orderEstAll(seg_all, isLine_all true);
% save seg_mytrain_clean_20140926 seg_all_order seg_all_clean;
% load ../expData/seg_mytrain_clean_20140926;

%% build hankel matrix
% [dscA_all_H, dscA_all_HH] = buildHankelAll(dscA_all_clean, hankel_size, 1);
% save HH_dscA_mytrain_20140930 dscA_all_H dscA_all_HH;
% load ../expData/HH_dscA_mytrain_20140930;
% [seg_all_H, seg_all_HH] = buildHankelAll(seg_all_clean, hankel_size, 1);
% save HH_mytrain_20140926 dscA_all_H dscA_all_HH seg_all_H seg_all_HH;
% load ../expData/HH_mytrain_20140926;
[dscA_all_H, dscA_all_HH] = buildHankelAll(dscA_all, hankel_size, 1);
[seg_all_H, seg_all_HH] = buildHankelAll(seg_all, hankel_size, 1);

%% normalized singular value estimation
dscA_all_sigma = sigmaEstAll(dscA_all_H, isLine_all, true);
% save sigma_dscA_mytrain_20140930 dscA_all_sigma
% load ../expData/sigma_dscA_mytrain_20140930

%% pooling
sampleNum = 10000;
poolMaxSize = 50000;
% [dscAPool, dscAPoolOrder, dscAPoolH, dscAPoolHH] = pooling(dscA_all_clean, dscA_all_order, [], dscA_all_H, dscA_all_HH, sampleNum, poolMaxSize);
% [dscAPool, dscAPoolOrder, dscAPoolSigma, dscAPoolH, dscAPoolHH] = pooling(dscA_all, dscA_all_order, dscA_all_sigma, dscA_all_H, dscA_all_HH, sampleNum, poolMaxSize);
[dscAPool, dscAPoolOrder, dscAPoolSigma, dscAPoolH, dscAPoolHH] = pooling(dscA_all, [], dscA_all_sigma, dscA_all_H, dscA_all_HH, sampleNum, poolMaxSize);
% save dscAPool_20140930 dscAPool dscAPoolOrder dscAPoolSigma dscAPoolH dscAPoolHH;
% load ../expData/dscAPool_20140930;
% [segPool, segPoolOrder, segPoolH, segPoolHH] = pooling(seg_all_clean, seg_all_order, [], seg_all_H, seg_all_HH, sampleNum, poolMaxSize);
% save segPool_20140926 segPool segPoolOrder segPoolH segPoolHH;
% load ../expData/segPool_20140926;

%% computer cluster centers
nc = 10;
% tic;
% [sLabel, centers, centers_order, centers_H, centers_HH, sD, centerInd] = nCutContourHH(dscAPool(1:10000), dscAPoolOrder(1:10000), dscAPoolH(1:10000), dscAPoolHH(1:10000), nc, alpha);
% toc
% save pedestrianCenters_a0_20140926 centers centers_order centers_H centers_HH sD centerInd sLabel;
% load ../expData/pedestrianCenters_20140919
% tic;
% [sLabel, centers, centers_sigma, centers_H, centers_HH, sD, centerInd] = nCutContourHHSigma(dscAPool(1:10000), dscAPoolSigma(:, 1:10000), dscAPoolH(1:10000), dscAPoolHH(1:10000), nc, alpha);
% toc
% save ped_dscA_centers_a001_20140930 centers centers_sigma centers_H centers_HH sD centerInd sLabel;
load ../expData/ped_dscACropped_centers_a001_20141001
% nc = 300;
% tic;
% % load ../expData/pedestrianCenters_seg_a0_20140926
% [sLabel, centers, centers_order, centers_H, centers_HH, sD, centerInd] = nCutContourHH(segPool(1:10000), segPoolOrder(1:10000), segPoolH(1:10000), segPoolHH(1:10000), nc, alpha);
% toc
% save centers_seg_w300_a001_20140926 centers centers_order centers_H centers_HH sD centerInd sLabel;
% load ../expData/centers_seg_w300_a001_20140926;

%% bow representation
% feat = bowFeatHHAll(dscA_all_HH, centers_HH, dscA_all_order, centers_order, alpha);
% save feat_mytrain_hOrder_a0_20140925 feat labels;
% load ../expData/feat_mytrain_hOrder_a0_20140925
% save feat_mytest_hOrder_a0_20140925 feat labels;
% load ../expData/feat_mytest_hOrder_a0_20140925
feat = bowFeatHHSigmaAll(dscA_all_HH, centers_HH, dscA_all_sigma, centers_sigma, alpha);
% save feat_mytrain_sigma_a001_20140930 feat labels;
% load ../expData/feat_mytrain_sigma_a001_20140930

% feat = bowFeatHHAll(seg_all_HH, centers_HH, seg_all_order, centers_order, alpha);
% save feat_seg_mytrain_hOrder_a0_20140926 feat labels;
% load ../expData/feat_seg_mytrain_hOrder_a0_20140926;


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
% feat = feat(:,1:4832);
% labels = labels(1:4832);

% load ../expData/feat_mytrain_hOrder_a0_20140925;
X_train = feat;
y_train = labels;
% X_train = feat(:,1:4832);
% y_train = labels(1:4832);
% load ../expData/feat_mytest_hOrder_a0_20140925;
% X_test = feat;
% y_test = labels;
    
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