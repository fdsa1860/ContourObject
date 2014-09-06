% Test the Binlong's metric on the contour clustering and classification 

clear;clc;close all;
addpath(genpath('../3rdParty'));

% produce and sample the synthetic data
produce_step = 0.0001;
sample_step = 0.1;
X = produceData(produce_step, sample_step, 2);
n = numel(X);

%% Contour Clustering

% extract the features from contours
dxy = cell(1, n);
cA = cell(1, n);
dA = cell(1, n);
for i = 1:n
    [dxy{i}, cA{i}, dA{i}] = extractFeature(X{i});
end

% detect the straight lines 
nL = 1;   
id_line = [];
for i = 1:n
    inf_cA = norm(cA{i}, inf);
    if inf_cA < 0.001
        id_line(nL) = i;
        nL = nL + 1;
    end
end

id_left = setdiff(1:n, id_line);
n_left = numel(id_left);

% build the Hankel matrix for the rest of contours
h_size = 15;
H = cell(1, n_left);
HHp = cell(1, n_left);
order_info = zeros(1, n_left);
%t = 0.998;     % the threshold for the cumulative angle
t = 0.98;          % the threshold for the derivative of cumulative angle 
for i = 1:n_left
    [H{i}, HHp{i}] = buildHankel(dA{id_left(i)}, h_size, 1);
    order_info(i) = getOrder(H{i}, t);    
end

%D = dynamicDistance(HHp, 1:n_left);                % Binlong's metric
D = dynamicDistance(HHp, 1:n_left, order_info);   % combine Binlong's metric with order

%showDistanceMatrix(D);

k = 8;      % number of clustering for the contours except lines
label = Ncuts(D, k, order_info);   % Normalized cuts

% calculate the intra-class and inter-class distances 
DistAtClass = zeros(k, k);
for i = 1:k
    id1 = find(label == i);
    for j = 1:k
        id2 = find(label == j);
        if i == j
            DistAtClass(i, j) = max(max(D(id1, id2)));
        else
            DistAtClass(i, j) = min(min(D(id1, id2)));
        end
    end    
end

%showDistanceMatrix(DistAtClass);

% re-label the contours including lines and others
if isempty(id_line) == 0
    reLabel = zeros(1, n);
    for i = 1:n
        if any(id_line == i)
            reLabel(i) = 1;
        elseif any (id_left == i)
            reLabel(i) = label(id_left == i) + 1;
        end
    end
    k = k + 1;
    label = reLabel;
end

showContours(X, k, label);

%% Contour Segment Classification 

% chop the contour trajectories into contour segments
segmentLength = 100;
[segment, segment_id] = chopContour(X, segmentLength);

% extract the feature of contour segments
nseg = numel(segment);
scA = cell(1, nseg);
for i = 1:nseg
    [~, scA{i}, ~] = extractFeature(segment{i});
end

% chop the cumulative angle of the original contour trajectories into segments
% then calculate the derivative and normalize it
sdA = cell(1, nseg);
m = 1;
for i = 1:n
    ncA = numel(cA{i});
    for j = 1:segmentLength:ncA
        ncA_left = ncA - j + 1;
        if ncA_left < segmentLength - 2
            break;
        end
        
        cAi = cA{i}(j:j+segmentLength-3);
        sdA{m} = cAi(2:end) - cAi(1:end-1);
%         sdA{m}(abs(sdA{m}) < 0.00001) = 0.00001;
%         sdA{m} = 10 .* sdA{m} / norm(sdA{m}, 1);
        
        m = m + 1;
    end    
end

% build the Hankel matrix for contour segments
sH = cell(1, nseg);
sHHp = cell(1, nseg);
sorder = zeros(1, n_left);
for i = 1:nseg
    [sH{i}, sHHp{i}] = buildHankel(sdA{i}, h_size, 1);
    sorder(i) = getOrder(sH{i}, t);    
end

% detect the line segments 
nsL = 1;  
id_sline = [];
for i = 1:nseg
    inf_scA = norm(scA{i}, inf);
    if inf_scA < 0.001
        id_sline(nsL) = i;
        nsL = nsL + 1;
    end   
end

% classify the contour segments
slabel = zeros(1, nseg);
for i = 1:nseg
    if any (id_sline == i)
        slabel(i) = 1;
        continue;
    end
    
    Ds = zeros(1, k);
    Ds(1) = 100;
    for j = 2:k
        id = find(label == j);
        D2C = zeros(1, numel(id));
        for m = 1:numel(id)
            p = find(id_left == id(m));
            D2C(m) = abs(2 - norm(HHp{p} + sHHp{i}, 'fro'));           
        end
        Ds(j) = min(D2C);
    end
    
    [~, slabel(i)] = min(Ds);
    
end

showContours(segment, k, slabel);

%% Contour Segment Classification 

hankel_size = 15;

% chop the contour trajectories into contour segments
segmentLength = 100;
[segment, segment_id] = chopContour(X, segmentLength);

numCont = numel(segment);
contourA = cell(1, numCont);         % cumulative angle
dcontourA = cell(1, numCont);       % the derivative of cumulative angle
eachLength = zeros(1, numCont);  % the length of each contour trajectory

H = cell(1, numCont);                     
HHp = cell(1, numCont);
order_info = zeros(1, numCont);

for i = 1:numCont
    eachLength(i) = size(segment{i}, 1);
    [~, contourA{i}, ~] = cumulativeAngle([segment{i}(:, 2) segment{i}(:, 1)]); 
    dcontourA{i} = diff(contourA{i});
    [H{i}, HHp{i}] = buildHankel(contourA{i}, hankel_size, 1);
    
    % 0.995 for synthetic, 0.98 for 296059 and 241004
    order_info(i) = getOrder(H{i}, 0.995);       
end

threshold = 0.14;
corners_index = detectCorners(dcontourA, threshold);

% chop contours at corners into segments
subSegment = chopContourAtCorner(segment, corners_index);

numSubSeg = numel(subSegment);

% display the contour segments chopped at corners
hFig = figure;
set(hFig, 'Position', [200 100 800 600]);
hold on;

for i = 1:numSubSeg
    plot(subSegment{i}(:, 2), subSegment{i}(:, 1), 'LineWidth', 1.5);
end

hold off;
axis equal;
axis ij;
% axis([0 imgSize(2) 0 imgSize(1)]);
xlabel('x', 'FontSize', 14);
ylabel('y', 'FontSize', 14);
title('Contour Segments chopped at corners', 'FontSize', 12);

% cluster the contour segments
scA = cell(1, numSubSeg);         % cumulative angle for segments
dscA = cell(1, numSubSeg);       % the derivative of cumulative angle for segments
sL = zeros(1, numSubSeg);       % the length of each contour segment
norm_scA = zeros(1, numSubSeg);

sH = cell(1, numSubSeg);
sHHp = cell(1, numSubSeg);
sorder = zeros(1, numSubSeg);

nL = 1;
line_id = [];         % the index of straight lines

for i = 1:numSubSeg
    sL(i) = size(subSegment{i}, 1);
    [~, scA{i}, ~] = cumulativeAngle([subSegment{i}(:, 2) subSegment{i}(:, 1)]);
    dscA{i} = diff(scA{i});
    
    % detect straight lines
    % 1 for synthetic, 0.8 for 296059 and 241004
    norm_scA(i) = norm(dscA{i}, 2);
    if norm_scA(i) < 1e-4
        line_id(nL) = i;
        nL = nL + 1;
    end
    
    [sH{i}, sHHp{i}] = buildHankel(dscA{i}, hankel_size, 1);
    
    % 0.9495 for synthetic, 0.99 for 296059, 0.98 for 241004
    sorder(i) = getOrder(sH{i}, 0.95);
end

% set the order of lines zero
sorder(line_id) = 0;

% sD = dynamicDistance(sHHp, 1:numSubSeg);
% sk = 4;      % number of clusters
sD = dynamicDistance(sHHp, 1:numSubSeg, sorder);
sk = numel(unique(sorder));

slabel = Ncuts(sD, sk, sorder);
showContours(subSegment, sk, slabel);
% plotContoursFromImage(subSegment, segment_pixel, sk, slabel, imgSize, sL);
% title(['Number of class: ' num2str(sk) ', Feature: cumulative angle'], 'FontSize', 12);

















