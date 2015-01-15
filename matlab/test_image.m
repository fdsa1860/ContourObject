% Test the Binlong's metric on the contour clustering and classification in images
close all;clear;clc;
addpath(genpath('../3rdParty'));
addpath(genpath('../matlab'));
addpath(genpath('../mex'));

% load image
% I = im2double(imread('../inputData/image/synthetic.jpg'));    % synthetic image
% I = im2double(imread('../inputData/image/296059.jpg'));  % natural image from BSDS500
% I = im2double(imread('../inputData/image/241004.jpg'));
I = im2double(imread('../inputData/image/kids.png'));
% I = im2double(imread('../../../data/INRIAPerson/mytrain/pos/crop_000010a.png'));

% parameters
hankel_size = 4;
alpha = 0;
hankel_mode = 1;
nBins = 9;

minLen = 2*hankel_size+2;
tic
profile on;
%% get cont
cont = img2cont(I);
% contour = img2contour_fast(I);

%% get map
numCont = length(cont.seg_line) + length(cont.seg_notLine);
map(1:numCont) = struct('pts',[0 0], 'label', 0);

slope = slopeEst(cont.seg_line);
points_line = cont.points_line;
cells.bbox = [1 1 cont.imgSize(2) cont.imgSize(1)];
cells.num = 1;
cells.nr = 8;
cells.nc = 8;
[~, ind_line] = structureLineFeat(slope, nBins, points_line, cells);
count = 1;
for i = 1:length(ind_line)
    map(count).pts = points_line(i,:);
    map(count).label = ind_line(i);
    count = count + 1;
end

% load centers
load ../expData/voc_dsca_notLine_centers_w10_a0_h4_20141016;

dscaNotLine = cont.dscA_notLine;
points_notLine = cont.points_notLine;
numSeg_notLine = length(dscaNotLine);
seg(1:numSeg_notLine) = struct('dsca',[], 'H',[], 'HH',[]);
for i = 1:numSeg_notLine
    seg(i).dsca = dscaNotLine{i};
    [seg(i).H, seg(i).HH] = buildHankel(seg(i).dsca, hankel_size, hankel_mode);
end
seg = sigmaEst(seg);
seg = addPoints(seg, points_notLine);
[~, ind_notLine] = structureBowFeatHHSigma(seg, centers, alpha, cells);
for i = 1:length(ind_notLine)
    map(count).pts = points_notLine(i,:);
    map(count).label = ind_notLine(i)+nBins;
    count = count + 1;
end
profile viewer
toc
%% show image
color = hsv(19);
I = zeros([cont.imgSize,3]);
for i = 1:length(map)
    x = max(1, floor(map(i).pts(1)));
    y = max(1, floor(map(i).pts(2)));
    I(y, x, :) = color(map(i).label, :);
end
imshow(I);
hbar = colorbar;
set(hbar, 'YTickLabel', [1:19]);
