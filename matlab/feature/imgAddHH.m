function img = imgAddHH(img)

seg = img.seg;
if isempty(img.contour), img.seg = []; return; end
numSeg = length(seg);
for i = 1:numSeg
    % H = hankel_mo(seg(i).vel');
    H = mexHankel(seg(i).vel');
    HH = (H * H') / norm (H * H', 'fro');
    seg(i).H = H;
    seg(i).HH = HH;
end
img.seg = seg;

end