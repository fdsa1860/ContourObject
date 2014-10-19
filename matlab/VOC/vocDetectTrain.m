% train detector
function detector = vocDetectTrain(VOCopts, cls, centers)

% load 'train' image set
ids=textread(sprintf(VOCopts.imgsetpath,'train'),'%s');

% extract features and bounding boxes
detector.FD=[];
detector.bbox=[];
detector.gt=[];
dscaNotLineAll = cell(1, length(ids));
tic;
for i=1:length(ids)
    % display progress
    if toc>1
        fprintf('%s: train: %d/%d\n',cls,i,length(ids));
        drawnow;
        tic;
    end
    
    % read annotation
    rec=PASreadrecord(sprintf(VOCopts.annopath,ids{i}));
    
    % find objects of class and extract difficult flags for these objects
    clsinds = ismember({rec.objects(:).class},cls);
    diff = [rec.objects(:).difficult];
    
    % assign ground truth class to image
    if ~any(clsinds)
        gt=-1;          % no objects of class
    elseif any(~diff)
        gt=1;           % at least one non-difficult object of class
    else
        gt=0;           % only difficult objects
    end
    
    if gt
        % extract features for image
        try
            % try to load features
            load(sprintf(VOCopts.exfdpath,ids{i}),'cont');
        catch
            % compute and save features
            I=imread(sprintf(VOCopts.imgpath,ids{i}));
            cont = img2cont(I,0);
            save(sprintf(VOCopts.exfdpath,ids{i}),'cont');
        end
        
        dscaNotLineAll{i} = cont.dscA_notLine;
        
        ind = find(~diff);
        for j = 1:nnz(ind)
            % extract bounding boxes for non-difficult objects
            bb = rec.objects(ind(j)).bbox;
            detector.bbox(end+1, :) = bb;
            % mark image as positive or negative
            detector.gt(end+1) = 2*clsinds(ind(j))-1;
            feat = cont2feat(cont, centers, bb);
            detector.FD(1:length(feat),end+1) = feat;
        end
        
    end
end

detector.model = svmtrain(detector.gt',sparse(detector.FD'),'-t 0');

end