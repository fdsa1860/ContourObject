 
%% set up environment
clc;clear;close all;
addpath(genpath('../3rdParty'));
addpath(genpath('../matlab'));

% opt = 'mytrain';
opt = 'mytest';

verbose = true;

%% load data
posDir = sprintf('../../../data/INRIAPerson/%s/pos/', opt);
negDir = sprintf('../../../data/INRIAPerson/%s/neg/', opt);
[imgList, labels] = loadImgList(posDir, negDir);

if strcmp(opt, 'mytrain')
    margin = 16;
elseif strcmp(opt, 'mytest')
    margin = 3;
end

numImg = length(imgList);
feat = zeros(128/8 * (64/8) * 4*9, numImg);
for i = 1:numImg
    img_raw = single(imread(imgList{i}))/255;
    img = img_raw(margin+1:end-margin, margin+1:end-margin, :);
    H = hog(img,8,9);
    feat(:, i) = H(:);
    if verbose
        fprintf('Processing image %d ... \n', i);
    end
end
if verbose
    fprintf('Process finished!\n');
end

% X_train = feat;
% y_train = labels;
% save hog_train_20141006 X_train y_train
% X_test = feat;
% y_test = labels;
% save hog_test_20141006 X_test y_test
%%
load ../expData/hog_train_20141006;
load ../expData/hog_test_20141006;

libsvmClassify(X_train, y_train, X_test, y_test);



