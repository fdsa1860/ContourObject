% test_caltech101

close all;clear;clc;
addpath(genpath('../3rdParty'));
addpath(genpath('../matlab'));

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
opt.hankel_size = 4;
opt.alpha = 0;
opt.hankel_mode = 1;
opt.nBins = 9;
opt.minLen = 2 * opt.hankel_size + 2;
opt.draw = false;
% load centers
load ../expData/voc_dsca_notLine_centers_w10_a0_h4_20141016;
%% load image
time_start = tic;
nImg = length(imgList);
img_all = cell(1, nImg);
for i = 1:nImg
    fprintf('Processing image %d ...\n', i);
    img.opt = opt;
    img.imgFile = imgList{i};
    img.centers = centers;
    img.gt = gtLabel(i);
    [~, img] = img2contourCode(img);
    img_all{i} = img;
end
fprintf('finish!\n');
toc(time_start)
save img_all_w10a0h4_caltech101_20141027 img_all

