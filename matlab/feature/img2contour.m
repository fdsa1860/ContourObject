function contour = img2contour(I, draw)

if nargin < 2
    draw = false;
end

imgSize = [size(I,1) size(I,2)];

% contour detection
% 1 is Canny for synthetic image
% 2 is Structured edge for natural image (P. Dollar's Method)
contour_raw = extractContours(I, 2, draw);
if isempty(contour_raw), contour=[]; return; end

% rankminimization to reduce the effect of discretization
hankel_size = 4;
lambda = 5;
contour_clean = rankminimize(contour_raw, hankel_size, imgSize, lambda);

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
contour_chopped = chopContourAtCorner(contour_clean, corners_index);
[contour_chopped] = filterContourWithFixedLength(contour_chopped, 2*hankel_size);

numContour = numel(contour_chopped);
% hstln denoise
contour_chopped_clean = cell(1, numContour);
eta_thr = 0.3;
for i = 1:numContour
    [tmp,~,~,R] = fast_incremental_hstln_mo(contour_chopped{i}',eta_thr);
    contour_chopped_clean{i} = tmp';
end

scA = cell(1, numContour);  % cumulative angle for segments
dscA = cell(1, numContour); % the derivative of cumulative angle for segments
for i = 1:numContour
    [~, scA{i}, ~] = cumulativeAngle([contour_chopped_clean{i}(:, 2) contour_chopped_clean{i}(:, 1)]);
    dscA{i} = diff(scA{i});
end

% filter length
hankel_size = 4;
[dscA, dscA_ind] = filterContourWithFixedLength(dscA, 2*hankel_size);
if ~isempty(contour_chopped_clean), contour_chopped_clean = contour_chopped_clean(dscA_ind); end

numContour = length(dscA);
contour(1:numContour) = struct('points',[], 'dsca',[]);
for i = 1:numContour
    contour(i).points = contour_chopped_clean{i};
    contour(i).dsca = dscA{i};
end


end