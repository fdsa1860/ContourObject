function [dscA_all, seg_all, imgSize_all] = img2dscaAll(imgList, opt, draw, verbose)

if nargin < 4
    verbose = false;
end
if nargin < 3
    draw = false;
end

if strcmp(opt, 'mytrain')
    margin = 16;
elseif strcmp(opt, 'mytest')
    margin = 3;
end

numImg = length(imgList);
dscA_all = cell(1, numImg);
seg_all = cell(1, numImg);
imgSize_all = zeros(numImg, 2);
for i = 1:numImg
    img_raw = im2double(imread(imgList{i}));
    img = img_raw(margin+1:end-margin, margin+1:end-margin, :);
    [dscA, seg, imgSize] = img2dscA(img, draw);
    dscA_all{i} = dscA;
    seg_all{i} = seg;
    imgSize_all(i, :) = imgSize;
    if verbose
        fprintf('Processing image %d ... \n', i);
    end
end
if verbose
    fprintf('Process finished!\n');
end

end