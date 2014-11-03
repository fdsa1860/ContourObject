% test_objDetContourCode

close all;clear;clc;
addpath(genpath('../3rdParty'));
addpath(genpath('../matlab'));

%% load image
%% load data
inputDir = sprintf('~/research/data/caltech101/%s/pos/', opt);
[imgList, labels] = loadImgList(posDir, negDir);

% parameters
opt.hankel_size = 4;
opt.alpha = 0;
opt.hankel_mode = 1;
opt.nBins = 9;
opt.minLen = 2 * opt.hankel_size + 2;
opt.draw = false;

img.opt = opt;
img.imgFile = imFile;

% load centers
load ../expData/voc_dsca_notLine_centers_w10_a0_h4_20141016;
img.centers = centers;

%% function get object contour code, which should be a cell data
[contCode, img] = img2contourCode(img);

%% get histogram on this code, which is the feature
feat = contourCode2feat(img);

%% load different images and compare them