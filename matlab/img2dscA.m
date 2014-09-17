function dscA = img2dscA(img)


imgSize = size(img);

% contour detection
% 1 is Canny for synthetic image
% 2 is Structured edge for natural image (P. Dollar's Method)
contour = extractContours(img, 2);

% rankminimization to reduce the effect of discretization
Size = imgSize(1:2);
hankel_size = 4;
lambda = 5;
contour_clean = rankminimize(contour, hankel_size, Size, lambda);

% resample
mode = 1; % fixed length
fixedLen = 1;
contour_clean = sampleAlongCurve(contour_clean, mode, fixedLen);

numCont = numel(contour_clean);
contourA = cell(1, numCont);         % cumulative angle
dcontourA = cell(1, numCont);       % the derivative of cumulative angle

for i = 1:numCont
    [~, contourA{i}, ~] = cumulativeAngle([contour_clean{i}(:, 2) contour_clean{i}(:, 1)]);
    dcontourA{i} = diff(contourA{i});
end

% detect corners on contours
% by finding the local extremum of the derivative of cumulative angle
threshold = 0.3;
corners_index = detectCorners(dcontourA, threshold);

% chop contours at corners into segments
segment = chopContourAtCorner(contour_clean, corners_index);
[segment, segmentInd] = filterContourWithFixedLength(segment, 2*hankel_size);

numSeg = numel(segment);
% hstln denoise
seg2 = cell(1, numSeg);
eta_thr = 0.6;
for i = 1:numSeg
    [seg_tmp,~,~,R] = fast_incremental_hstln_mo(segment{i}',eta_thr);
    seg2{i} = seg_tmp';
end
segment = seg2;

MEAN_THRES = 0.005;
STD_THRES = 0.05;
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
line_id = [];         % the index of straight lines

for i = 1:numSeg
    sL(i) = size(segment{i}, 1);
    [~, scA{i}, ~] = cumulativeAngle([segment{i}(:, 2) segment{i}(:, 1)]);
    dscA{i} = diff(scA{i});
    
    %     % denoise feature
    %     [dscA_tmp,~,~,R] = fast_incremental_hstln_mo(dscA{i}',0.3);
    %     dscA{i} = dscA_tmp';
    
    % detect straight lines
    % 1 for synthetic, 0.8 for 296059 and 241004
    abs_mean_dscA(i) = abs(mean(dscA{i}));
    std_dscA(i) = std(dscA{i});
    abs_sum_dscA(i) = abs(sum(dscA{i}));
    norm_dscA(i) = norm(dscA{i}, 2);
    if abs_mean_dscA(i) < MEAN_THRES && std_dscA(i) < STD_THRES
        %     if abs_sum_dscA(i) < SUM_THRES && norm_dscA(i) < NORM_THRES
        line_id(nL) = i;
        nL = nL + 1;
    end
    
    [sH{i}, sHHp{i}] = buildHankel(dscA{i}, hankel_size, 1);
    
    % 0.9495 for synthetic, 0.99 for 296059, 0.98 for 241004
    sorder(i) = getOrder(sH{i}, 0.95);
end

% set the order of lines zero
sorder(line_id) = 0;

end