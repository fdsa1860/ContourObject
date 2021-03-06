function generateImagePatch

% opt = 'mytrain';
opt = 'mytest';

if strcmp(opt, 'mytrain')
negDir = '../../../../data/INRIAPerson/train_64x128_H96/neg/';
fileList = dir(fullfile(negDir,'*.png'));
outputDir = '../../../../data/INRIAPerson/mytrain/neg/';
% set width and height of bounding boxes
width = 96;
height = 160;
elseif strcmp(opt, 'mytest')
negDir = '../../../../data/INRIAPerson/test_64x128_H96/neg/';
fileList = dir(fullfile(negDir,'*.png'));
outputDir = '../../../../data/INRIAPerson/mytest/neg/';
width = 70;
height = 134;
end
% set random seed
rng('default');


numBox = 10;
n = length(fileList);
%% loop
for i = 1:n
    % read image
    [~,fileName,extName] = fileparts(fileList(i).name);
    img = imread(fullfile(negDir,fileList(i).name));
    imgHeight = size(img, 1);
    imgWidth = size(img, 2);
    topLeftHeightMax = imgHeight - height + 1;
    topLeftWidthMax = imgWidth - width + 1;
    % generate 10 bounding boxes for each image
    topLeftY = randi(topLeftHeightMax, numBox, 1);
    topLeftX = randi(topLeftWidthMax, numBox, 1);
    % crop ROI image
    for j = 1:numBox
        ROI = img(topLeftY(j):topLeftY(j)+height-1,topLeftX(j):topLeftX(j)+width-1,:);
        imgName = [fileName '_' sprintf('%02d',j) extName];
        % write image
        imwrite(ROI,fullfile(outputDir,imgName));
    end
    
end


end