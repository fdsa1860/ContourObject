function cont = img2cont(img, draw)

if nargin < 2
    draw = false;
end

imgSize = [size(img,1) size(img,2)];

% contour detection
% 1 is Canny for synthetic image
% 2 is Structured edge for natural image (P. Dollar's Method)
contour = extractContours(img, 2, draw);
if isempty(contour), cont=[]; return; end

% rankminimization to reduce the effect of discretization
hankel_size = 4;
lambda = 5;
contour_clean = rankminimize(contour, hankel_size, imgSize, lambda);
% contour_clean = contour;

% resample
mode = 1; % fixed length
fixedLen = 1;
contour_clean = sampleAlongCurve(contour_clean, mode, fixedLen);

% filter length
hankel_size = 4;
[contour_clean] = filterContourWithFixedLength(contour_clean, 2*hankel_size);

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
eta_thr = 0.3;
for i = 1:numSeg
    [seg_tmp,~,~,R] = fast_incremental_hstln_mo(segment{i}',eta_thr);
    seg2{i} = seg_tmp';
end
segment = seg2;

scA = cell(1, numSeg);  % cumulative angle for segments
dscA = cell(1, numSeg); % the derivative of cumulative angle for segments
for i = 1:numSeg
    [~, scA{i}, ~] = cumulativeAngle([segment{i}(:, 2) segment{i}(:, 1)]);
    dscA{i} = diff(scA{i});
%     dscA{i} = conv(scA{i}, [-1 0 0 0 1], 'valid');
end

% filter length
hankel_size = 4;
[dscA, dscA_ind] = filterContourWithFixedLength(dscA, 2*hankel_size);
if ~isempty(segment), segment = segment(dscA_ind); end

% segment with sliding window
if isempty(dscA) || isempty(segment), cont=[]; return; end
[dscA, segment, points] = slideWindowChopContour(dscA, segment, 2*hankel_size);
% line detection
isLine = dscaLineDetect(dscA);
% separate line and non-line
cont.dscA_line = dscA(isLine);
cont.dscA_notLine = dscA(~isLine);
cont.seg_line = segment(isLine);
cont.seg_notLine = segment(~isLine);
cont.points_line = points(isLine, :);
cont.points_notLine = points(~isLine, :);
cont.imgSize = imgSize;


end