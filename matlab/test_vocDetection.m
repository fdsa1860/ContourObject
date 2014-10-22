% function test_vocDetection

clc;close all;clear;
% change this path if you install the VOC code elsewhere
addpath(genpath('../3rdParty/VOCdevkit/VOCcode/'));
addpath(genpath('../3rdParty/'));
addpath(genpath('../matlab'));

% initialize VOC options
VOCinit;

% train and test detector for each class
for i=1:VOCopts.nclasses
% for i=2
    cls=VOCopts.classes{i};
    load ../expData/voc_dsca_notLine_centers_w10_a0_h4_20141016;
%     detector = [];
    detector = vocDetectTrain(VOCopts, cls, centers);       % train detector
    save(sprintf('voc_detector_%s_20141016', cls), 'detector');
%     load(sprintf('../expData/voc_detector_%s_20141016', cls), 'detector');
    vocDetectTest(VOCopts, cls, detector, centers);         % test detector
    [recall,prec,ap]=VOCevaldet(VOCopts,'comp3',cls,true);  % compute and display PR
    
    if i<VOCopts.nclasses
        fprintf('press any key to continue with next class...\n');
        drawnow;
        pause;
    end
end