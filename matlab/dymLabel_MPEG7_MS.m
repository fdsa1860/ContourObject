%
% label test_BSDS500 with dynamic info

%% set up environment
clc;clear;close all;
addpath(genpath('../3rdParty'));
addpath(genpath('../matlab'));
addpath(genpath('../mex'));

dataDir = '~/research/data/MPEG7';

% parameters
opt.hankel_size = 10;
opt.sampleMode = 1;
opt.sampleLen = 1;
opt.minLen = 2 * opt.hankel_size + 2;
opt.segLength = 2 * opt.hankel_size + 1;
opt.alpha = 0;
opt.draw = true;
opt.verbose = true;
opt.metric = 'HtH';
% opt.metric = 'HHt';

%% get file name list
files = dir(fullfile(dataDir,'*.gif'));
n = length(files);
fileNameList = cell(1, n);
for i = 1:n
    fileNameList{i} = fullfile(dataDir,files(i).name);
end

%% load cluster centers
% load ../expData/bsds_centers_w10_h10_a0_s5_o1_HtH_20150309
% load ../expData/bsds_centers_w30_h10_a0_s5h_o1_HtH_20150314
% load ../expData/mpeg7_centers_w30_h10_a0_s5_o1_HtH_20150305.mat;
% load ../expData/mpeg7_centers_w10_h10_a0_knn_HtH_20150305.mat
load ../expData/mpeg7_centers_w10_h10_a0_s5_o1_HtH_20150322
% load ../expData/mpeg7_centers_w10_h10_a0_s3_o1_HHt_20150322

%% show correspondence map
for i = 1:n
% for i = 241
    fprintf('Processing image %d/%d ...\n', i,n);
    [~,fname,ext] = fileparts(fileNameList{i});
    I = imread(fileNameList{i});
    R = I;
    try
        load(sprintf('../expData/MPEG7_ms_segments/seg_%s.mat',fname),'seg','shortSeg');
    catch
        cont = extractContFromRegion(R);
        contour = sampleAlongCurve(cont, opt.sampleMode, opt.sampleLen);
        contour = filterContourWithFixedLength(contour, opt.segLength);
        contour = filterContourWithLPF(contour);
        [seg, shortSeg] = contour2segModelSwitch(contour, opt);
        seg = addHH(seg,opt.hankel_size);
        seg = sigmaEst(seg);
        save(sprintf('../expData/MPEG7_ms_segments/seg_%s.mat',fname),'seg','shortSeg');
    end
    seg = addHH(seg, opt.hankel_size, opt.metric);
    seg = sigmaEst(seg);
    
    clear map;
    map(1:length(seg)) = struct('pts',[0 0], 'label', 0);
    
    hgt = size(R, 1);
    wid = size(R, 2);
    D = dynamicDistanceSigmaCross(seg, centers, opt.alpha);
    [val,ind] = min(D, [], 2);
    
    count = 1;
    for j = 1:length(seg)
        for jj = 1:size(seg(j).points, 1)
            map(count).pts = [seg(j).points(jj,2) seg(j).points(jj,1)];
            map(count).label = ind(j);
            count = count + 1;
        end
    end
    % include short segments to map and give them a special label
    nc = length(centers);
    for j = 1:length(shortSeg)
        for jj = 1:size(shortSeg(j).points, 1)
            map(count).pts = [shortSeg(j).points(jj,2) shortSeg(j).points(jj,1)];
            map(count).label = nc + 1;
            count = count + 1;
        end
    end
    
    dymBoundaries = zeros(hgt, wid, 'uint8');
    for j = 1:length(map)
        x = min(wid, max(1, round(map(j).pts(1))));
        y = min(hgt, max(1, round(map(j).pts(2))));
        dymBoundaries(y, x) = map(j).label;
    end
    
    % show image
    % imagesc(dymGT);
%     save(sprintf('../expData/MPEG7_ms_segments/%s.mat', fname), 'dymBoundaries');
if opt.draw
    E = dymEdgeDraw(dymBoundaries, nc);
    imwrite(im2uint8(E),sprintf('../expData/MPEG7_dymEdgeImage/%s.png', fname));
    %     imshow(E);
end
    %     pause;
%     keyboard;
end

1