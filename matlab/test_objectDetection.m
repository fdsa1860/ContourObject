% object detection

%% set up environment
clc;clear;close all;

%% load data

% load positive images name list
posDir = '/Users/xikang/Documents/data/INRIAPerson/train_64x128_H96/pos/';
% posList = importdata('/Users/xikang/Documents/data/INRIAPerson/train_64x128_H96/pos.lst');
fileList = dir(fullfile(posDir,'*.png'));

% posList

% load negative images
% negList

% merge
numImg = length(fileList);
imgList = cell(1, numImg);
for i = 1:numImg
    imgList{i} = fullfile(posDir,fileList(i).name);
end
% label

% load cluster centers
load('../expData/clusterCenters.mat');

%% compute contours, then features
nc = length(centers);
N = length(imgList);
feat = zeros(nc, N);
for i = 1:length(imgList)
    img = im2double(imread(imgList{i}));
    dscA = img2dscA(img);
    feat(:,i) = bowFeat(dscA, centers);
end

%% bow representation
% compute centers
% cntrInd = findCenters(sD, slabel);
% centers = dscA(cntrInd);
% save cluster centers

%% display

%% svm classification to test how hard the data is to classify