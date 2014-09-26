% object detection

%% set up environment
clc;clear;close all;
addpath(genpath('../3rdParty'));
addpath(genpath('../matlab'));

hankel_size = 4;
alpha = 0;

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
tic
numImg = length(imgList);
dscA_all = cell(1, numImg);
seg_all = cell(1, numImg);
for i = 1:numImg
    img = im2double(imread(imgList{i}));
    [dscA, seg] = img2dscA(img);
    dscA_all{i} = dscA;
    seg_all{i} = seg;
    fprintf('Processing image %d ... \n', i);
end
fprintf('Process finished!\n');
toc
save dscASeg_mytrain_raw_20140926 dscA_all seg_all;
load ../expData/dscASeg_mytrain_raw_20140926
% save dscASeg_mytest_raw_20140926 dscA_all seg_all;
% load ../expData/dscA_mytest_raw_20140926


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
% save dscA_mytest_clean_20140924 dscA_all_clean dscA_all_order dscA_all_H dscA_all_HH;
load ../expData/dscA_mytrain_clean_20140919
% load ../expData/dscA_mytest_clean_20140924

%% pooling
% sampleNum = 10000;
% poolMaxSize = 50000;
% [contourPool, poolOrder, poolH, poolHH] = pooling(dscA_all_clean, dscA_all_order, dscA_all_H, dscA_all_HH, sampleNum, poolMaxSize);
% save contourPool_20140925 contourPool poolOrder poolH poolHH;
load ../expData/contourPool_20140925;

%% computer cluster centers
% nc = 10;
% tic;
% [sLabel, centers, centers_order, centers_H, centers_HH, sD, centerInd] = nCutContourHH(contourPool(1:10000), poolOrder(1:10000), poolH(1:10000), poolHH(1:10000), nc, alpha);
% toc
% save pedestrianCenters_a0_20140925 centers centers_order centers_H centers_HH sD centerInd sLabel;
load ../expData/pedestrianCenters_a0_20140925

%% bow representation
% nc = length(centers);
% numImg = length(dscA_all_HH);
% feat = zeros(nc, numImg);
% for i = 1:numImg
%     if isempty(dscA_all_HH{i})
%         feat(:,i) = zeros(nc,1);
%     else
%         feat(:,i) = bowFeatHH(dscA_all_HH{i}, centers_HH, dscA_all_order{i}, centers_order, alpha);
%     end
% end
% save feat_mytrain_hOrder_a0_20140925 feat labels;
% load ../expData/feat_mytrain_hOrder_a0_20140925
% save feat_mytest_hOrder_a0_20140925 feat labels;
% load ../expData/feat_mytest_hOrder_a0_20140925


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

load ../expData/feat_mytrain_hOrder_a0_20140925;
X_train = feat;
y_train = labels;
% X_train = feat(:,1:4832);
% y_train = labels(1:4832);
load ../expData/feat_mytest_hOrder_a0_20140925;
X_test = feat;
y_test = labels;
    
% K = 5;
% ind = crossvalind('Kfold',length(labels),K);
% accuracyCross = zeros(1, K);
% for k = 1:K
%     X_train = feat(:,ind~=k);
%     X_test = feat(:,ind==k);
%     y_train = labels(ind~=k);
%     y_test = labels(ind==k);
    
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
%     accuracyCross(k) = accuracy;
% end
rmpath(genpath('../3rdParty/liblinear-1.94/matlab'));