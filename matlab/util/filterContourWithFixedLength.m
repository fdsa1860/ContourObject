
function [segment, index] = filterContourWithFixedLength(segment, fixedLength)

numSeg = length(segment);
% numSeg = numel(segment);
index = true(numSeg,1);
for i = 1:numSeg
    if(size(segment(i).points, 1) < fixedLength)
%     if length(segment{i}) < fixedLength
        index(i) = false;
    end
end

segment = segment(index);