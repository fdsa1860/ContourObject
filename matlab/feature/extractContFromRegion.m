function cont = extractContFromRegion(R)
% Extract contours from a segmentation image using contour following
% Input:
% R: segmentation image or region image
% Output:
% cont: output contours, cell array

nMax = 1000;
w = size(R, 2);
h = size(R, 1);
label = unique(R);
nR = length(label);
cont = cell(1, nMax);
cnt = 1;
for i = 1:nR
    b = bwboundaries(R==label(i), 8);
    for j = 1:length(b)
        ind = b{j}(:,1)==1 | b{j}(:,1)==h | b{j}(:,2)==1 | b{j}(:,2)==w;
        ind = ~ind;
        seg = curveSplit(b{j}, ind);
        segLen = cellfun('length',seg);
        seg(segLen<3) = [];
        for k = 1:length(seg)
            cont(cnt) = seg(k);
            cnt = cnt + 1;
        end
    end
end
if cnt>=nMax, keyboard; end
cont(cnt:end) = [];

end