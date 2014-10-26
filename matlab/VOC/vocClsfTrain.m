% train classifier
function [classifier, dscaNotLineAll] = vocClsfTrain(VOCopts, cls, centers)

if ~exist('centers','var')
    centers = [];
end

% load 'train' image set for class
[ids,classifier.gt]=textread(sprintf(VOCopts.clsimgsetpath,cls,'train'),'%s %d');

% ignore the difficult samples
id_difficult = find(classifier.gt==0);
ids(id_difficult) = [];
classifier.gt(id_difficult) = [];

% extract features for each image
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
