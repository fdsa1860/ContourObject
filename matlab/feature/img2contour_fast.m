function contour = img2contour_fast(I, draw)

if nargin < 2
    draw = false;
end

% contour detection
% 1 is Canny for synthetic image
% 2 is Structured edge for natural image (P. Dollar's Method)
cont = extractContours(I, 2, draw);
if isempty(cont), contour=[]; return; end

% resample
mode = 1; % fixed length
fixedLen = 1;
cont = sampleAlongCurve(cont, mode, fixedLen);

% filter length
hankel_size = 7;
[cont] = filterContourWithFixedLength(cont, 2*hankel_size+1);
if isempty(cont), contour=[]; return; end

% segment with sliding window
contour = slideWindowChopContour_fast(cont, 2*hankel_size+1);

end