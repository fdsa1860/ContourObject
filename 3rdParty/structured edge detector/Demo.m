clear all;
clc;

I = imread('data/296059.jpg');
load('models/forest/modelFinal.mat');

model.opts.nms = 1;   % enable non-maximum suppression
tic, E = edgesDetect(I, model); toc
figure, imshow(E);

BW = im2bw(E, 0.20);
figure, imshow(BW);