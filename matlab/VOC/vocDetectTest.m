% run detector on test images
function out = vocDetectTest(VOCopts, cls, detector, centers)

% load test set ('val' for development kit)
[ids,gt]=textread(sprintf(VOCopts.imgsetpath,VOCopts.testset),'%s %d');
model=load('structuredEdgeDetector/models/forest/modelBsds'); model=model.model;
model.opts.multiscale=0; model.opts.sharpen=2; model.opts.nThreads=4;
% set up opts for edgeBoxes (see edgeBoxes.m)
opts = edgeBoxes;
opts.alpha = .65;     % step size of sliding window search
opts.beta  = .75;     % nms threshold for object proposals
opts.minScore = .01;  % min score of boxes to detect
opts.maxBoxes = 1e4;  % max number of boxes to detect
% create results file
fid=fopen(sprintf(VOCopts.detrespath,'comp3',cls),'w');

% apply detector to each image
tic;
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

    I=imread(sprintf(VOCopts.imgpath,ids{i}));
    bbs = edgeBoxes( I, model, opts );
    % compute confidence of positive classification and bounding boxes
    [c,BB]=vocDetect(VOCopts,detector,cont,centers, bbs);

    % write to results file
    for j=1:length(c)
        fprintf(fid,'%s %f %d %d %d %d\n',ids{i},c(j),BB(:,j));
    end
end

% close results file
fclose(fid);
