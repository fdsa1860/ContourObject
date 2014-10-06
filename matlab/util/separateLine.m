function [dscA_line_all, dscA_notLine_all, seg_line_all, seg_notLine_all, points_line_all, points_notLine_all] = separateLine(dscA_all, seg_all, points_all, isLine_all, verbose)

if nargin < 5
    verbose = false;
end

if verbose
    fprintf('separating lines and non-lines ...');
end

numImg = length(dscA_all);
dscA_line_all = cell(1, numImg);
dscA_notLine_all = cell(1, numImg);
seg_line_all = cell(1, numImg);
seg_notLine_all = cell(1, numImg);
points_line_all = cell(1, numImg);
points_notLine_all = cell(1, numImg);
for i = 1:numImg
    dscA_line_all{i} = dscA_all{i}(isLine_all{i});
    dscA_notLine_all{i} = dscA_all{i}(~isLine_all{i});
    seg_line_all{i} = seg_all{i}(isLine_all{i});
    seg_notLine_all{i} = seg_all{i}(~isLine_all{i});
    points_line_all{i} = points_all{i}(isLine_all{i}, :);
    points_notLine_all{i} = points_all{i}(~isLine_all{i}, :);
end

if verbose
    fprintf('finished!\n');
end

end