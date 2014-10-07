function [dscA, segment, imgSize] = img2dscA2(img, draw)

if nargin < 2
    draw = false;
end

imgSize = [size(img,1) size(img,2)];

% contour detection
% 1 is Canny for synthetic image
% 2 is Structured edge for natural image (P. Dollar's Method)
contour = extractContours(img, 2, draw);
if isempty(contour)
    dscA = [];
    segment = [];
    return;
end


% resample
mode = 1; % fixed length
fixedLen = 1;
contour_clean = sampleAlongCurve(contour, mode, fixedLen);

numCont = numel(contour_clean);
contourA = cell(1, numCont);         % cumulative angle
dcontourA = cell(1, numCont);       % the derivative of cumulative angle

for i = 1:numCont
    [~, contourA{i}, ~] = cumulativeAngle([contour_clean{i}(:, 2) contour_clean{i}(:, 1)]);
    dcontourA{i} = diff(contourA{i});
end
dscA = dcontourA;
segment = contour_clean;
% % detect corners on contours
% % by finding the local extremum of the derivative of cumulative angle
% threshold = 0.3;
% corners_index = detectCorners(dcontourA, threshold);
% 
% % chop contours at corners into segments
% segment = chopContourAtCorner(contour_clean, corners_index);
% [segment, segmentInd] = filterContourWithFixedLength(segment, 2*hankel_size);
% 
% numSeg = numel(segment);
% % hstln denoise
% seg2 = cell(1, numSeg);
% eta_thr = 0.3;
% for i = 1:numSeg
%     [seg_tmp,~,~,R] = fast_incremental_hstln_mo(segment{i}',eta_thr);
%     seg2{i} = seg_tmp';
% end
% segment = seg2;
% 
% scA = cell(1, numSeg);  % cumulative angle for segments
% dscA = cell(1, numSeg); % the derivative of cumulative angle for segments
% for i = 1:numSeg
%     [~, scA{i}, ~] = cumulativeAngle([segment{i}(:, 2) segment{i}(:, 1)]);
%     dscA{i} = diff(scA{i});
% end


end