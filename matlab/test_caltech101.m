% test_caltech101

close all;clear;clc;
addpath(genpath('../3rdParty'));
addpath(genpath('../matlab'));
addpath(genpath('../mex'));

baseDir = '~/research/data/caltech101';
annotationDir = fullfile(baseDir, 'Annotations');
clsDir = fullfile(baseDir, '101_ObjectCategories');
tmp = dir(clsDir);
tmp(1:4) = [];
cls = cell(1,101);
imgList = cell(1, 10000);
gtLabel = zeros(1, 10000);
count = 1;
for i = 1:length(tmp)
    cls{i} =  tmp(i).name;
    tmp2 = dir(fullfile(clsDir, cls{i}, '*.jpg'));
    for j = 1:length(tmp2)
        imgList{count} = fullfile(clsDir, cls{i}, tmp2(j).name);
        gtLabel(count) = i;
        count = count + 1;
    end
end
imgList(count:end) = [];
gtLabel(count:end) = [];

% parameters
opt.localDir = '/Users/xikangzhang/research/code/ContourObject/expData/caltech101/contour_%s_%05d';
opt.dataset = 'caltech101';
opt.hankel_size = 4;
opt.alpha = 0;
opt.hankel_mode = 1;
opt.nBins = 9;
opt.minLen = 2 * opt.hankel_size + 2;
opt.draw = false;
opt.verbose = true;

%% load image
time_start = tic;
%     [~, img] = img2contourCode(img);
img_all = img2contour_all(imgList, gtLabel, opt);
toc(time_start)
% save img_all_w10a0h4_caltech101_20141110 img_all

load ../expData/ped_centers_w100_a0_sig001_20141104

%% get feature
tic
% profile on;
numImg = length(img_all);
for i = 1:numImg
% for i = 1:1
    img = img_all{i};
    block = genBlock([1 1 img.width img.height], 4, 16);
    [feat, ind] = structureBowFeatHHSigma(img.seg, centers, opt.alpha, block);
%     feat(ind,:) = 0;
    img.feat = [];
    img.feat = feat;
    img_all{i} = img;
end
% profile viewer
toc

%% classify
numImg = length(img_all);
X_train = zeros(100*64, numImg);
for i = 1:numImg
    X_train(:,i) = img_all{i}.feat;
    y_train(i) = img_all{i}.label;
end
X_train = l2Normalization(X_train);
tic;[accMat, libsvmModel] = libsvmClassify(X_train, y_train);toc

