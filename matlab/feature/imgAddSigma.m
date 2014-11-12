function img = imgAddSigma(img)

seg = img.seg;
seg = sigmaEst(seg);
img.seg = seg;

end