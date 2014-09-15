
close all;clear;clc;

addpath(genpath('../3rdParty'));
    
load('../expData/kidsImageSegment.mat');

hankel_size = 4;
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

MEAN_THRES = 0.01;
STD_THRES = 0.1;
SUM_THRES = 0.5;
NORM_THRES = 0.1;
% cluster the contour segments
scA = cell(1, numSeg);         % cumulative angle for segments
dscA = cell(1, numSeg);       % the derivative of cumulative angle for segments
sL = zeros(1, numSeg);       % the length of each contour segment
norm_dscA = zeros(1, numSeg);
abs_mean_dscA = zeros(1, numSeg);
std_dscA = zeros(1, numSeg);
abs_sum_dscA = zeros(1, numSeg);

sH = cell(1, numSeg);
sHHp = cell(1, numSeg);
sorder = zeros(1, numSeg);

nL = 1;
line_id = false(1, numSeg);         % the index of straight lines

for i = 1:numSeg
    sL(i) = size(segment{i}, 1);

    [~, scA{i}, ~] = cumulativeAngle([segment{i}(:, 2) segment{i}(:, 1)]);
    dscA{i} = diff(scA{i});
%     h = [-1 0 1]';
%     dscA{i} = conv(scA{i},h,'valid');   % higher signal noise ratio
    
    % detect straight lines
    % 1 for synthetic, 0.8 for 296059 and 241004
    norm_dscA(i) = norm(dscA{i}, 2);
    abs_mean_dscA(i) = abs(mean(dscA{i}));
    abs_sum_dscA(i) = abs(sum(dscA{i}));
    std_dscA(i) = std(dscA{i});
%     if abs_mean_dscA(i) < MEAN_THRES && std_dscA(i) < STD_THRES
    if abs_sum_dscA(i) < SUM_THRES && norm_dscA(i) < NORM_THRES
        line_id(i) = true;
    end
    
    [sH{i}, sHHp{i}] = buildHankel(dscA{i}, hankel_size, 1);
    
    % 0.9495 for synthetic, 0.99 for 296059, 0.98 for 241004
    sorder(i) = getOrder(sH{i}, 0.99);
end

% set the order of lines zero
sorder(line_id) = 0;

% sD = dynamicDistance(sHHp, 1:numSeg);
% sk = 4;      % number of clusters
sD = dynamicDistance(sHHp, 1:numSeg, sorder);
sk = numel(unique(sorder));
% sk = 9;

slabel = Ncuts(sD, sk, sorder);
plotContoursFromImage(segment, segment_pixel, sk, slabel, imgSize, sL);
title(['Number of class: ' num2str(sk) ', Feature: cumulative angle'], 'FontSize', 12);
