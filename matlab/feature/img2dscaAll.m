function [dscA_all, seg_all] = img2dscaAll(imgList, draw, verbose)

if nargin < 3
    verbose = false;
end
if nargin < 2
    draw = false;
end

numImg = length(imgList);
dscA_all = cell(1, numImg);
seg_all = cell(1, numImg);
for i = 1:numImg
    img = im2double(imread(imgList{i}));
    [dscA, seg] = img2dscA(img, draw);
    dscA_all{i} = dscA;
    seg_all{i} = seg;
    if verbose
        fprintf('Processing image %d ... \n', i);
    end
end
if verbose
    fprintf('Process finished!\n');
end

end