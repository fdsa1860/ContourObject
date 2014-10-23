% Test the Binlong's metric on the contour clustering and classification in images
close all;clear;clc;
addpath(genpath('../3rdParty'));
addpath(genpath('../matlab'));

% load image
% img = im2double(imread('../inputData/image/synthetic.jpg'));    % synthetic image
% img = im2double(imread('../inputData/image/296059.jpg'));  % natural image from BSDS500
% img = im2double(imread('../inputData/image/241004.jpg'));
img = im2double(imread('../inputData/image/kids.png'));
% img = im2double(imread('../../../data/INRIAPerson/mytrain/pos/crop_000010a.png'));

% parameters
hankel_size = 4;
alpha = 0;
hankel_mode = 1;
nBins = 9;

minLen = 2*hankel_size+2;

%% get cont
cont = img2cont(img);

%% get map
numCont = length(cont.seg_line) + length(cont.seg_notLine);
map(1:numCont) = struct('pts',[0 0], 'label', 0);

slope = slopeEst(cont.seg_line);
points_line = cont.points_line;
block = [1 1 cont.imgSize(2) cont.imgSize(1)];
[~, ind_line] = structureLineFeat(slope, nBins, points_line, block);
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
[~, ind_notLine] = structureBowFeatHHSigma(seg, centers, alpha, points_notLine, block);
for i = 1:length(ind_notLine)
    map(count).pts = points_notLine(i,:);
    map(count).label = ind_notLine(i)+nBins;
    count = count + 1;
end

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

% D = dynamicDistance(HHp, 1:numCont);
% k = 5;      % number of clusters
D = dynamicDistanceSigma(HHp, 1:numCont, order_info);
k = numel(unique(order_info));

label = Ncuts(D, k, order_info);
plotContoursFromImage(contour_clean, contour, k, label, imgSize, eachLength);
title(['Number of class: ' num2str(k) ', Feature: cumulative angle'], 'FontSize', 12);

%%
MEAN_THRES = 0.005;
STD_THRES = 0.05;
SUM_THRES = 0.5;
NORM_THRES = 0.04;
dNORM_THRES = 0.1;
% cluster the contour segments
scA = cell(1, numSeg);         % cumulative angle for segments
dscA = cell(1, numSeg);       % the derivative of cumulative angle for segments
sL = zeros(1, numSeg);       % the length of each contour segment
norm_dscA = zeros(1, numSeg);
abs_mean_dscA = zeros(1, numSeg);
std_dscA = zeros(1, numSeg);
abs_sum_dscA = zeros(1, numSeg);
norm_scA = zeros(1, numSeg);
od = zeros(1, numSeg);

sH = cell(1, numSeg);
sHHp = cell(1, numSeg);
sorder = zeros(1, numSeg);
sigma = zeros(hankel_size, numSeg);

nL = 1;
line_id = [];         % the index of straight lines

for i = 1:numSeg
    sL(i) = size(segment{i}, 1);
    [~, scA{i}, ~] = cumulativeAngle([segment{i}(:, 2) segment{i}(:, 1)]);
    dscA{i} = diff(scA{i});
    
    % denoise feature
    [dscA_tmp,~,~,od(i)] = fast_incremental_hstln_mo(dscA{i}',0.01);
    dscA{i} = dscA_tmp';
    
    % detect straight lines
    % 1 for synthetic, 0.8 for 296059 and 241004
    abs_mean_dscA(i) = abs(mean(dscA{i}));
    std_dscA(i) = std(dscA{i});
    abs_sum_dscA(i) = abs(sum(dscA{i}));
    norm_dscA(i) = norm(dscA{i}, 2);
    norm_scA(i) = norm(scA{i})/length(scA{i});
%     if od(i) == 1
%     if  norm_scA(i) < NORM_THRES
    if norm_dscA(i) < dNORM_THRES
%     if abs_mean_dscA(i) < MEAN_THRES && std_dscA(i) < STD_THRES
        %     if abs_sum_dscA(i) < SUM_THRES && norm_dscA(i) < NORM_THRES
        line_id(nL) = i;
        nL = nL + 1;
    end
    
    [sH{i}, sHHp{i}] = buildHankel(dscA{i}, hankel_size, 1);
    
    % 0.9495 for synthetic, 0.99 for 296059, 0.98 for 241004
%     sorder(i) = getOrder(sH{i}, 0.95);
    sorder(i) = od(i);
    sigma(:, i) = svd(sH{i});
    sigma(:, i) = sigma(:, i) / sigma(1, i);
end

% set the order of lines zero
sorder(line_id) = 0;
sigma(:, line_id) = 0;

% sD = dynamicDistance(sHHp, 1:numSeg);
% sk = 4;      % number of clusters
sD = dynamicDistance(sHHp, 1:numSeg, sorder);
% sD = dynamicDistanceSigma(sHHp, 1:numSeg, sigma);
% sk = numel(unique(sorder));
sk = 10;

% slabel = Ncuts(sD, sk, sorder);
W = exp(-sD);     % the similarity matrix
NcutDiscrete = ncutW(W, sk);
slabel = sortLabel_order(NcutDiscrete, sorder);
% slabel = sortLabel_sigma(NcutDiscrete, sigma);
centerInd = findCenters(sD, slabel);

plotContoursFromImage(segment, segment_pixel, sk, slabel, imgSize, sL);
title(['Number of class: ' num2str(sk) ', Feature: cumulative angle'], 'FontSize', 12);

%% Contour segments clustering  Part II
%
% % chop contour trajectories into segments with same length
% FixedLength = 30;
% segment2 = chopContour(contour_clean, FixedLength);
% segment_pixel2 = chopContour(contour, FixedLength);
%
% numSeg2 = numel(segment2);
%
% scA2 = cell(1, numSeg2);         % cumulative angle for segments
% dscA2 = cell(1, numSeg2);       % the derivative of cumulative angle for segments
% sL2 = zeros(1, numSeg2);       % the length of each contour segment
% norm_scA2 = zeros(1, numSeg2);
%
% sH2 = cell(1, numSeg2);
% sHHp2 = cell(1, numSeg2);
% sorder2 = zeros(1, numSeg2);
%
% nL2 = 1;
% line_id2 = [];         % the index of straight lines
%
% for i = 1:numSeg2
%     sL2(i) = size(segment2{i}, 1);
%     [~, scA2{i}, ~] = cumulativeAngle([segment2{i}(:, 2) segment2{i}(:, 1)]);
%     dscA2{i} = diff(scA2{i});
%
%     % detect straight lines
%     norm_scA2(i) = norm(scA2{i}, 2);
%     % 0.3 for synthetic, 0.5 for 296059
%     if norm_scA2(i) < 0.5
%         line_id2(nL2) = i;
%         nL2 = nL2 + 1;
%     end
%
%     [sH2{i}, sHHp2{i}] = buildHankel(scA2{i}, hankel_size, 1);
%
%     % 0.95 for synthetic, 0.985 for 296059, 0.98 for 241004
%     sorder2(i) = getOrder(sH2{i}, 0.955);
% end
%
% % set the order of lines zero
% sorder2(line_id2) = 0;
%
% % sD2 = dynamicDistance(sHHp2, 1:numSeg2);
% % sk2 = 4;      % number of clusters
% sD2 = dynamicDistance(sHHp2, 1:numSeg2, sorder2);
% sk2 = numel(unique(sorder2));
%
% slabel2 = Ncuts(sD2, sk2, sorder2);
% plotContoursFromImage(segment2, segment_pixel2, sk2, slabel2, imgSize, sL2);
% title(['Number of class: ' num2str(sk2) ', Feature: cumulative angle, ' ...
%         'Length of segment: ' num2str(FixedLength)], 'FontSize', 12);


