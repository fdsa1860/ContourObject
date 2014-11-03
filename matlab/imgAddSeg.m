function img = imgAddSeg(img)

seg = [];
contour = img.contour;
numCont = length(contour);
for j = 1:numCont
    seg = [seg contour(j).seg];
end
img.seg = seg;

end