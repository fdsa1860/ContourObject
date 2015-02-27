
function [segment] = filterContourWithLPF(segment, h)

if nargin < 2
    sig = 1;
    h = fspecial('gaussian',[5 1],sig);
end

numSeg = length(segment);
for i = 1:numSeg
    isClosed = ~any(segment(i).points(1,:)-segment(i).points(end,:));
    if ~isClosed
        segment(i).points = imfilter(segment(i).points, h, 'replicate');
    else
        segment(i).points = imfilter(segment(i).points(1:end-1,:), h, 'circular');
        segment(i).points(end+1,:) = segment(i).points(1,:);
    end
end