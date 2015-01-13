% load VOC data structure

clc;close all;clear;
% change this path if you install the VOC code elsewhere
addpath(genpath('../3rdParty/'));
addpath(genpath('../matlab'));

% initialize VOC options
VOCinit;

% train and test classifier for each class
for i=1:VOCopts.nclasses
    cls=VOCopts.classes{i};
%     load ../expData/voc_dsca_notLine_centers_w10_a0_h4_20141016;
    [classifier, dscaNotLineAll] = vocClsfTrain(VOCopts,cls); % train classifier
    
    [centers, sLabel, sD] = vocClsfCluster(dscaNotLineAll);

    vocClsfTest(VOCopts, cls, classifier, centers); % test classifier
    [recall,prec,ap]=VOCevalcls(VOCopts,'comp1',cls,true);   % compute and display PR
    
    if i<VOCopts.nclasses
        fprintf('press any key to continue with next class...\n');
        drawnow;
%         keyboard;
%         pause
    end
end
