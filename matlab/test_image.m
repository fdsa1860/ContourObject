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

imgSize = size(img);

% parameters
hankel_size = 4;
minLen = 2*hankel_size+2;

%% contour detection
% 1 is Canny for synthetic image
% 2 is Structured edge for natural image (P. Dollar's Method)
contour = extractContours(img, 2);

%%
% rankminimization to reduce the effect of discretization
Size = imgSize(1:2);
lambda = 5;
contour_clean = rankminimize(contour, hankel_size, Size, lambda);

%% resample
mode = 1; % fixed length
fixedLen = 1;
contour_clean = sampleAlongCurve(contour_clean, mode, fixedLen);
contour_clean = filterContourWithFixedLength(contour_clean, minLen);

%% Contour trajectories clustering

numCont = numel(contour_clean);
contourA = cell(1, numCont);         % cumulative angle
dcontourA = cell(1, numCont);       % the derivative of cumulative angle
eachLength = zeros(1, numCont);  % the length of each contour trajectory

H = cell(1, numCont);
HHp = cell(1, numCont);
order_info = zeros(1, numCont);

for i = 1:numCont
    eachLength(i) = size(contour_clean{i}, 1);
    [~, contourA{i}, ~] = cumulativeAngle([contour_clean{i}(:, 2) contour_clean{i}(:, 1)]);
    dcontourA{i} = diff(contourA{i});
    [H{i}, HHp{i}] = buildHankel(contourA{i}, hankel_size, 1);
    
    % 0.995 for synthetic, 0.98 for 296059 and 241004
    order_info(i) = getOrder(H{i}, 0.995);
end

% D = dynamicDistance(HHp, 1:numCont);
% k = 5;      % number of clusters
D = dynamicDistance(HHp, 1:numCont, order_info);
k = numel(unique(order_info));

label = Ncuts(D, k, order_info);
plotContoursFromImage(contour_clean, contour, k, label, imgSize, eachLength);
title(['Number of class: ' num2str(k) ', Feature: cumulative angle'], 'FontSize', 12);

%% Contour segments clustering  Part I

% detect corners on contours
% by finding the local extremum of the derivative of cumulative angle

% 0.14 for synthetic, 0.085 for 296059 and 241004
threshold = 0.4;
corners_index = detectCorners(dcontourA, threshold);

% display corners in image
hFig = figure;
set(hFig, 'Position', [200 100 800 600]);
hold on;

for i = 1:numCont
    plot(contour_clean{i}(:, 2), contour_clean{i}(:, 1), 'LineWidth', 1.5);
    plot(contour_clean{i}(1, 2), contour_clean{i}(1, 1), 'bo');  % starting points of contours
    plot(contour_clean{i}(corners_index{i}, 2), contour_clean{i}(corners_index{i}, 1), ...
        'r*', 'MarkerSize', 10);
    
    %center = sum(contour_clean{i}) / eachLength(i);
    %text(center(2)-10, center(1)-2, num2str(i), 'FontSize', 13, 'Color', 'b');
end

hold off;
axis equal;
axis ij;
axis([0 imgSize(2) 0 imgSize(1)]);
xlabel('x', 'FontSize', 14);
ylabel('y', 'FontSize', 14);
title('Corner detection by finding local extreme of the derivative of cumulative angles', ...
    'FontSize', 12);

% chop contours at corners into segments
segment = chopContourAtCorner(contour_clean, corners_index);
% segment_pixel = chopContourAtCorner(contour, corners_index);

[segment, segmentInd] = filterContourWithFixedLength(segment, minLen);
% segment_pixel = segment_pixel(segmentInd);
segment_pixel = [];

numSeg = numel(segment);

% display the contour segments chopped at corners
hFig = figure;
set(hFig, 'Position', [200 100 800 600]);
hold on;

for i = 1:numSeg
    plot(segment{i}(:, 2), segment{i}(:, 1), 'LineWidth', 1.5);
    text(segment{i}(1, 2), segment{i}(1, 1), [' ' num2str(i)]);
end

hold off;
axis equal;
axis ij;
axis([0 imgSize(2) 0 imgSize(1)]);
xlabel('x', 'FontSize', 14);
ylabel('y', 'FontSize', 14);
title('Contour Segments chopped at corners', 'FontSize', 12);

%% hstln denoise
seg2 = cell(1, numSeg);
eta_thr = 0.6;
for i = 1:numSeg
    [seg_tmp,~,~,R] = fast_incremental_hstln_mo(segment{i}',eta_thr);
    seg2{i} = seg_tmp';
end
segment = seg2;

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
sk = 6;

% slabel = Ncuts(sD, sk, sorder);
% W = exp(-sD);     % the similarity matrix
% NcutDiscrete = ncutW(W, sk);
% slabel = sortLabel_order(NcutDiscrete, sorder);
W = exp(-sD);     % the similarity matrix
NcutDiscrete = ncutW(W, sk);
slabel = sortLabel_sigma(NcutDiscrete, sigma);

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


