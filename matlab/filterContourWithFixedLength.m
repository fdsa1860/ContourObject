
function [segment, index] = filterContourWithFixedLength(segment, fixedLength)

numSeg = numel(segment);
index = true(numSeg,1);
for i = 1:numSeg
    if length(segment{i}) < fixedLength
        index(i) = false;
    end
end

segment = segment(index);