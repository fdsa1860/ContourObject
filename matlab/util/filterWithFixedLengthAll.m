function [dscA_all, seg_all, dscA_ind] = filterWithFixedLengthAll(dscA_all, seg_all, maxLen)

numImg = length(dscA_all);
for i = 1:numImg
    [dscA_all{i}, dscA_ind] = filterContourWithFixedLength(dscA_all{i}, maxLen);
    if ~isempty(seg_all)
        seg_all{i} = seg_all{i}(dscA_ind);
    end
end

end