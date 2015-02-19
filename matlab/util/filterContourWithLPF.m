
function [segment] = filterContourWithLPF(segment, h)

if nargin < 2
    sig = 1;
    h = fspecial('gaussian',[5 1],sig);
end

numSeg = length(segment);
for i = 1:numSeg
    segment(i).points = imfilter(segment(i).points, h, 'replicate');
end