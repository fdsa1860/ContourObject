% load VOC data structure

function testVOC

clc;close all;clear;
% change this path if you install the VOC code elsewhere
addpath(genpath('../3rdParty/VOCdevkit/VOCcode/'));
addpath(genpath('../3rdParty/'));
addpath(genpath('../matlab'));

% initialize VOC options
VOCinit;

% train and test classifier for each class
for i=1:VOCopts.nclasses
    cls=VOCopts.classes{i};
    [classifier, dscaNotLineAll] = train(VOCopts,cls);             % train classifier
    
%     % build hankel matrix
%     hankel_size = 4;
%     dscaNotLineAll_data = buildHankelAll(dscaNotLineAll, hankel_size, 1, true);
%     % normalized singular value estimation
%     dscaNotLineAll_data = sigmaEstAll(dscaNotLineAll_data);
%     % pooling
%     poolMaxSize = 50000;
%     dscaNotLinePool = pooling(dscaNotLineAll_data, poolMaxSize);
%     % computer cluster centers
%     nc = 10; alpha = 0;
%     % load ../expData/ped_dscA_notLine_sD_a0_20141012
%     tic;
%     [centers, sLabel, sD] = nCutContourHHSigma(dscaNotLinePool(1:10000), nc, alpha);
%     toc
%     save voc_dsca_notLine_sD_a0_20141016 sD;
%     save voc_dsca_notLine_centers_w10_a0_h4_20141016 centers sLabel;
%     load ../expData/voc_dsca_notLine_centers_w10_a0_h4_20141016
    
    
    
    test(VOCopts,cls,classifier);                            % test classifier
    [recall,prec,ap]=VOCevalcls(VOCopts,'comp1',cls,true);   % compute and display PR
    
    if i<VOCopts.nclasses
        fprintf('press any key to continue with next class...\n');
        drawnow;
        pause;
    end
end

% train classifier
function [classifier, dscaNotLineAll] = train(VOCopts,cls)

% load 'train' image set for class
[ids,classifier.gt]=textread(sprintf(VOCopts.clsimgsetpath,cls,'train'),'%s %d');

% ignore the difficult samples
id_difficult = find(classifier.gt==0);
ids(id_difficult) = [];
classifier.gt(id_difficult) = [];

% extract features for each image
load ../expData/voc_dsca_notLine_centers_w10_a0_h4_20141016
classifier.FD=zeros(0,length(ids));
dscaNotLineAll = cell(1, length(ids));
tic;
for i=1:length(ids)
    % display progress
    if toc>1
        fprintf('%s: train: %d/%d\n',cls,i,length(ids));
        drawnow;
        tic;
    end

    try
        % try to load features
        load(sprintf(VOCopts.exfdpath,ids{i}),'cont');
    catch
        % compute and save features
        I=imread(sprintf(VOCopts.imgpath,ids{i}));
%         fd=extractfd(VOCopts,I);
        cont = img2cont(I,0);
        save(sprintf(VOCopts.exfdpath,ids{i}),'cont');
    end

    dscaNotLineAll{i} = cont.dscA_notLine;
    
    feat = cont2feat(cont, centers);
    classifier.FD(1:length(feat),i) = feat;
    
end

classifier.model = svmtrain(classifier.gt,sparse(classifier.FD'),'-t 0');

% run classifier on test images
function test(VOCopts,cls,classifier)

% load test set ('val' for development kit)
% [ids,gt]=textread(sprintf(VOCopts.imgsetpath,VOCopts.testset),'%s %d');
[ids, gt]=textread(sprintf(VOCopts.clsimgsetpath,cls,'val'),'%s %d');

% ignore the difficult samples
id_difficult = find(gt==0);
ids(id_difficult) = [];
gt(id_difficult) = [];

% create results file
fid=fopen(sprintf(VOCopts.clsrespath,'comp1',cls),'w');

% classify each image
tic;
% fd_all = zeros(36, length(ids));
load ../expData/voc_dsca_notLine_centers_w10_a0_h4_20141016;
for i=1:length(ids)
    % display progress
    if toc>1
        fprintf('%s: test: %d/%d\n',cls,i,length(ids));
        drawnow;
        tic;
    end
    
    try
        % try to load features
        load(sprintf(VOCopts.exfdpath,ids{i}),'cont');
    catch
        % compute and save features
        I=imread(sprintf(VOCopts.imgpath,ids{i}));
%         fd=extractfd(VOCopts,I);
        cont = img2cont(I,0);
        save(sprintf(VOCopts.exfdpath,ids{i}),'cont');
    end
    
    feat = cont2feat(cont, centers);
%     fd_all(:, i) = feat;
    % compute confidence of positive classification
%     c=classify(VOCopts,classifier,fd);
    [lb, acc, conf] = svmpredict(1, sparse(feat'), classifier.model);
    % write to results file
    fprintf(fid,'%s %f\n',ids{i},conf);
end
% [predict_label, acc, dec] = svmpredict(gt, sparse(fd_all'), classifier.model);
% accuracy = nnz(predict_label==gt)/length(gt);
% accuracy
% close results file
fclose(fid);

% trivial feature extractor: compute mean RGB
function fd = extractfd(VOCopts,I)

fd=squeeze(sum(sum(double(I)))/(size(I,1)*size(I,2)));

% trivial classifier: compute ratio of L2 distance betweeen
% nearest positive (class) feature vector and nearest negative (non-class)
% feature vector
function c = classify(VOCopts,classifier,fd)

d=sum(fd.*fd)+sum(classifier.FD.*classifier.FD)-2*fd'*classifier.FD;
dp=min(d(classifier.gt>0));
dn=min(d(classifier.gt<0));
c=dn/(dp+eps);
