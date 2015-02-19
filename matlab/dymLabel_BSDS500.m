%
% label test_BSDS500 with dynamic info

%% set up environment
clc;clear;close all;
addpath(genpath('../3rdParty'));
addpath(genpath('../matlab'));
addpath(genpath('../mex'));

dataDir = '~/research/data/BSR/BSDS500/data';

% parameters
opt.hankel_size = 7;
opt.sampleMode = 1;
opt.sampleLen = 1;
opt.minLen = 2 * opt.hankel_size + 2;
opt.segLength = 2 * opt.hankel_size + 1;
opt.numSubjects = 6;
opt.alpha = 0;
opt.draw = false;
opt.verbose = true;
opt.dataset = 'test';

%% get file name list
files = dir(fullfile(dataDir,'groundTruth',opt.dataset,'*.mat'));
n = length(files);
fileNameList = cell(1, n);
for i = 1:n
    fileNameList{i} = fullfile(dataDir,'groundTruth',opt.dataset,files(i).name);
end


%% load cluster centers
load ../expData/bsds_centers_w10_h7_a0_sig001_20150114

%% show correspondence map
% for i = 1:n
for i = 139
    [~,fname,ext] = fileparts(fileNameList{i});
    t = importdata(fileNameList{i});
%     I = imread(sprintf(fullfile(dataDir,'images',opt.dataset,'%s.jpg'), fname));
    dymGroundTruth = cell(1, length(t));
    for k = 1:length(t)
%         bw = t{k}.Boundaries; cont = extractContBW(single(bw));   
        R = t{k}.Segmentation; cont = extractContFromRegion(R);
        contour = sampleAlongCurve(cont, opt.sampleMode, opt.sampleLen);
        contour = filterContourWithFixedLength(contour, opt.segLength);
        seg = slideWindowContour2Seg(contour, opt.segLength);
        seg = addHH(seg);
        seg = sigmaEst(seg);
        
        clear map;
        map(1:length(seg)) = struct('pts',[0 0], 'label', 0);

        hgt = size(R, 1);
        wid = size(R, 2);
        cells.bbox = [1 1 wid hgt];
        cells.nr = 1;
        cells.nc = 1;
        cells.num = 1;
        [~, ind] = structureBowFeatHHSigma(seg, centers, opt.alpha, cells);
        
        count = 1;
        for j = 1:length(ind)
            map(count).pts = seg(j).loc;
            map(count).label = ind(j);
            count = count + 1;
        end
        
        dymBoundaries = zeros(hgt, wid, 'uint8');
        for j = 1:length(map)
            x = max(1, floor(map(j).pts(1)));
            y = max(1, floor(map(j).pts(2)));
            dymBoundaries(y, x) = map(j).label;
        end
        % show image
        % imagesc(dymGT);
        dymGroundTruth{k}.dymBoundaries = dymBoundaries;
    end
    save(sprintf('../expData/dymGroundTruth/%s/%s.mat', opt.dataset, fname), 'dymGroundTruth');
    %     pause;
    %     keyboard;
end

1