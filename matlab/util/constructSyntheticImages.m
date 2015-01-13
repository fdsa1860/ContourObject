% construct synthetic images

function constructSyntheticImages

obj = getObject;
obj_w = size(obj, 2);
obj_h = size(obj, 1);

imgDir = '~/research/data/pascal/VOC2007/JPEGImages/%s';
files = dir(sprintf(imgDir,'*.jpg'));

outDir = '~/research/data/pascal/VOC2007_occl/%s';

gt1 = load(sprintf('~/research/data/pascal/VOC2007/ImageSets/Main/aeroplane_%s.txt','trainval'));
gt2 = load(sprintf('~/research/data/pascal/VOC2007/ImageSets/Main/aeroplane_%s.txt','test'));
gt = [gt1; gt2];
gt = sortrows(gt, 1);

assert(length(gt)==length(files));

rng('default');
numImg = length(files);
for i = 1:numImg
    fprintf('processing %d/%d ...\n', i, numImg);
    
    if gt(i,2)==-1
        copyfile(sprintf(imgDir, files(i).name), sprintf(outDir, files(i).name));
    elseif gt(i,2)==1
        I = imread(sprintf(imgDir, files(i).name));
        w = size(I, 2);
        h = size(I, 1);
        
        ratio = min(w/obj_w/1.5, h/obj_h/1.5);
        scaled = imresize(obj, ratio);
        scaled_w = size(scaled, 2);
        scaled_h = size(scaled, 1);
        msk = (scaled~=0);
        
        x = randi(w-scaled_w);
        y = randi(h-scaled_h);
        I1 = im2double(I);
        I1(y:y+scaled_h-1, x:x+scaled_w-1, :) = scaled.*msk + I1(y:y+scaled_h-1, x:x+scaled_w-1, :).*(~msk);
        % imshow(I1);
        imwrite(I1, sprintf(outDir, files(i).name));
    end
    
    
    
end

end

function obj = getObject

thres = 0.15;

img = imread('../../expData/bag.png');
bg = imread('../../expData/bg.png');

I3 = abs(im2double(rgb2gray(img))-im2double(rgb2gray(bg))) > thres;


se = strel('disk',10);
I4 = imclose(I3,se);
% imshow(I3);
I5 = imfill(I4,'holes');
% imshow(I4);

blob = medfilt2(I5);
% imshow(blob);

cc= bwconncomp(blob);
lens = cellfun(@length, cc.PixelIdxList);
[~,ind] = max(lens);    % ind is the index of majority nonzero pixels
L = labelmatrix(cc);

mask = zeros(size(img));
mask(:,:,1) = (L==ind);
mask(:,:,2) = (L==ind);
mask(:,:,3) = (L==ind);

I6 = im2double(img).*mask;
% imshow(I6);

[r, c] = ind2sub(size(L),find(L==ind));

obj = I6(min(r):max(r),min(c):max(c),:);
imshow(obj);

% imwrite(obj, '../../expData/obj.png');

end