%
% label test_BSDS500 with dynamic info

%% set up environment
clc;clear;close all;
addpath(genpath('../3rdParty'));
addpath(genpath('../matlab'));
addpath(genpath('../mex'));

dataDir = '~/research/data/BSR/BSDS500/data';

% parameters
opt.hankel_size = 10;
opt.sampleMode = 1;
opt.sampleLen = 1;
opt.minLen = 2 * opt.hankel_size + 2;
opt.segLength = 2 * opt.hankel_size + 1;
opt.numSubjects = 6;
opt.alpha = 0;
opt.draw = true;
opt.verbose = true;
opt.dataset = 'train';

%% get file name list
files = dir(fullfile(dataDir,'groundTruth',opt.dataset,'*.mat'));
n = length(files);
fileNameList = cell(1, n);
for i = 1:n
    fileNameList{i} = fullfile(dataDir,'groundTruth',opt.dataset,files(i).name);
end


%% load cluster centers
% load ../expData/bsds_centers_w10_h10_a0_sig001_20150221
% load ../expData/bsds_centers_w10_h10_a0_s5_o1_HtH_20150309
% load ../expData/bsds_centers_w10_h10_a0_s5_o1_HtH_20150225
% load ../expData/bsds_centers_w28_h10_a0_s5_o1_HtH_20150225
% load ../expData/bsds_centers_w10_h10_a0_s5_o1_HtH_knn20_20150309
% load ../expData/bsds_centers_w22_h10_a0_s6_o1_HtH_greedy_20150313
% load ../expData/bsds_centers_w24_h10_a0_s6_o1_HtH_greedy2_20150313
% load ../expData/bsds_centers_w16_h10_a0_s5_o1_HtH_greedy2_20150313
% load ../expData/bsds_centers_w18_h10_a0_s6_o1_HtH_20150314
% load ../expData/bsds_centers_w13_h10_a0_s5_o1_HtH_20150314
% load ../expData/bsds_centers_w30_h10_a0_s5_o2_HtH_20150314
% load ../expData/bsds_centers_w30_h10_a0_s5h_o1_HtH_20150314
load ../expData/bsds_centers_w31_h10_a0_s6_o1_HtH_20150314
% load ../expData/bsds_centers_w32_h10_a0_s3e6_o1_HtH_20150314
% load ../expData/bsds_centers_w19_h10_a0_s5_o1_HtH_20150315

%% show correspondence map
for i = 1:n
% for i = [ 139 193]
    [~,fname,ext] = fileparts(fileNameList{i});
    t = importdata(fileNameList{i});
%     I = imread(sprintf(fullfile(dataDir,'images',opt.dataset,'%s.jpg'), fname));
    dymGroundTruth = cell(1, length(t));
    for k = 1:length(t)
        R = t{k}.Segmentation;
%         R = imresize(R,2,'bilinear');
        try
            load(sprintf('../expData/ModelSwitchSegments/seg_%s_%d_%d.mat',opt.dataset,i,k),'seg','shortSeg');
        catch
            cont = extractContFromRegion(R);
            contour = sampleAlongCurve(cont, opt.sampleMode, opt.sampleLen);
            contour = filterContourWithFixedLength(contour, opt.segLength);
            contour = filterContourWithLPF(contour);
            [seg, shortSeg] = contour2segModelSwitch(contour, opt);
            seg = addHH(seg,opt.hankel_size);
            seg = sigmaEst(seg);
            save(sprintf('../expData/ModelSwitchSegments/seg_%s_%d_%d.mat',opt.dataset,i,k),'seg','shortSeg');
        end
        
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
        dymGroundTruth{k}.dymBoundaries = dymBoundaries;
    end
    save(sprintf('../expData/dymGroundTruth/%s/%s.mat', opt.dataset, fname), 'dymGroundTruth');

    if opt.draw
        nc = length(centers);
        for j = 1:length(dymGroundTruth)
            E = dymEdgeDraw(dymGroundTruth{j}.dymBoundaries,nc);
            imwrite(im2uint8(E),sprintf('../expData/dymGroundTruthImg/%s/%s_gt%d_w%d.png', opt.dataset, fname, j, nc));
%             hFig = figure;
%             set(hFig, 'Position', [100*(j-1)+1 200*(j-1)+1 100*j 200*j]);
%             set(gca,'YDir','reverse');
%             imshow(E);
        end
    end
    
    %     pause;
%     keyboard;
end

1