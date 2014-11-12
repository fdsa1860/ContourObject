% car detection

close all;clc;clear;

%% load contours
rawContourPath = '/home/xikang/research/code/ContourObject/raw_contour';
rawContourFiles = dir(fullfile(rawContourPath,'*.mat'));
maxNum = 10000;
contourPool = cell(1,maxNum);
counter = 0;
segLen = 46;
for i=1:length(rawContourFiles)
    currContour = importdata(fullfile(rawContourPath,rawContourFiles(i).name));
    currContour = splitContour(currContour,segLen);
    tmpSize = length(currContour);
    if counter+tmpSize > maxNum
        break;
    end
    contourPool(counter+1:counter+tmpSize) = currContour;
    counter = counter + tmpSize;
end
contourPool(counter+1:end) = [];

%% hstln
addpath('../3rdParty/hstln');
seg2 = cell(size(contourPool));
eta_thr = 0.6;
for si=1:length(contourPool)
    seg_v = diff(contourPool{si}(1:8:end,:));
    [seg_v2,~,~,R] = fast_incremental_hstln_mo(seg_v',eta_thr);
    R
    seg2{si} = seg_v2';
end
% rmpath('../3rdParty/hstln');

%% cluster contours
numClusters = 6;
figure(5);
labelColor = 'bgrmcyk';
% [label,X_center] = kmeansContour(seg2,3);
[label,X_center,cntrInd,W] = nCutContour(seg2(1:100),numClusters);
% for si = 1:length(seg)
%     hold on;plot(seg{si}(:,1),seg{si}(:,2));hold off;
% end
seg = contourPool(1:100);
for si = 1:length(seg)
    hold on;plot(seg{si}(:,1),seg{si}(:,2),labelColor(label(si)));hold off;
    set(gca,'YDir','Reverse');
end
for ci = 1:length(cntrInd)
    hold on;plot(seg{cntrInd(ci)}(:,1),seg{cntrInd(ci)}(:,2),[labelColor(ci),'o']);hold off;
    set(gca,'YDir','Reverse');
end

%% 
filteredContourPath = '/home/xikang/research/code/ContourObject/filtered_contour';
filteredContourFiles = dir(fullfile(filteredContourPath,'*.mat'));
contourHist = zeros(numClusters,length(filteredContourFiles));
for i=1:length(filteredContourFiles)
    % load a car's contour
    currContour = importdata(fullfile(filteredContourPath,filteredContourFiles(i).name));
    currContour = splitContour(currContour,segLen);

    % get histogram
    if isempty(currContour)
        continue;
    end
    h = findSubspaceAngleHist(X_center, currContour, 1);
    contourHist(:,i) = h';
%     bar(h);
%     i
%     pause;
end
meanHist = mean(contourHist,2);

%% test car detection on image
file = '/home/xikang/research/code/ContourObject/3Dobject/car/car_01/car_A1_H1_S3.bmp';
% for i=1:length(contourFiles)
detection = [];
thres = 0.01;
for i=3
    currContour = importdata(fullfile(rawContourPath,rawContourFiles(i).name));
    currContour = splitContour(currContour,segLen);
    I = imread(file);
    [wid,hgt,~] = size(I);
    for x_tl = 1:10:90
        for y_tl = 1:10:90
            bb = [x_tl y_tl 300 230];
            Msk = zeros(wid,hgt);
            Msk(bb(1):bb(1)+bb(3)-1,bb(2):bb(2)+bb(4)-1) = 1;
            filteredContour = filterContours(currContour,Msk);
            h = findSubspaceAngleHist(X_center, filteredContour, 1);
            
            if norm(meanHist-h') < thres
                norm(meanHist-h')
                detection = [detection;bb];
            end
        end
    end
end
detection

imshow(I);
for bi = 1:size(detection,1)
hold on;rectangle('Position',detection(bi,:),'EdgeColor','g'); hold off;
end
