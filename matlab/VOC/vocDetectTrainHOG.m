% train detector
function detector = vocDetectTrainHOG(VOCopts, cls)

OV_THRES = 0.5;
BBSNUM_MAX = 10;

% load object proposal model and parameters
model=load('edges/models/forest/modelBsds'); model=model.model;
model.opts.multiscale=0; model.opts.sharpen=2; model.opts.nThreads=4;
% set up opts for edgeBoxes (see edgeBoxes.m)
opts = edgeBoxes;
opts.alpha = .65;     % step size of sliding window search
opts.beta  = .75;     % nms threshold for object proposals
opts.minScore = .01;  % min score of boxes to detect
opts.maxBoxes = 1e4;  % max number of boxes to detect

% load 'train' image set
ids=textread(sprintf(VOCopts.imgsetpath,'train'),'%s');

% extract features and bounding boxes
Dim = 2304;
N_MAX = 120000;
detector.FD= zeros(Dim, N_MAX, 'single');
detector.bbox = zeros(N_MAX, 4);
detector.gt = zeros(1, N_MAX);
counter = 1;
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
            load(sprintf(VOCopts.hogtrainfdpath,ids{i}),'bbs','labels','FD');
        catch
            % compute and save features
            interval = 4;
            FD = zeros(Dim, 2*BBSNUM_MAX*interval);
            bbs = zeros(2*BBSNUM_MAX*interval, 4);
            labels = zeros(1, 2*BBSNUM_MAX*interval);
            cnt = 1;
            
            bbs_gt = cat(1, rec.objects(~diff & clsinds).bbox);
            I = imread(sprintf(VOCopts.imgpath,ids{i}));

            sc = 2^(1/interval);
            for si = 1:interval
                
                I_scaled = imresize(I, 1/sc^(si-1),'bilinear');
                bbs_gt_scaled = round(bbs_gt/sc^(si-1));
                
                rec_prop = edgeBoxes(I_scaled, model, opts );
                bbs_prop = [rec_prop(:,1:2), rec_prop(:,1:2)+rec_prop(:,3:4)-1];
                labels_prop = -ones(1, size(bbs_prop, 1));
                if ~isempty(bbs_gt_scaled)
                    for pi = 1:size(bbs_prop, 1)
                        ov_max = 0;
                        for gi = 1:size(bbs_gt_scaled, 1)
                            ov = bbOverlap(bbs_prop(pi,:), bbs_gt(gi,:));
                            if ov > ov_max, ov_max = ov; end
                        end
                        if ov_max > OV_THRES, labels_prop(pi) = 1; end
                    end
                end
                
                bbs_scale = [bbs_gt_scaled; bbs_prop];
                labels_scale = [ ones(1, size(bbs_gt_scaled, 1)), labels_prop];
                
                bbs_pos = bbs_scale(labels_scale==1, :);
                bbs_neg = bbs_scale(labels_scale==-1, :);
                nP = min(nnz(labels_scale==1), BBSNUM_MAX);
                nN = min(nnz(labels_scale==-1), BBSNUM_MAX);
                bbs_scale = [bbs_pos(1:nP, :); bbs_neg(1:nN, :)];
                labels_scale = [ones(1, nP), -ones(1, nN)];

                nValid = nP + nN;
                FD_scale = zeros(Dim, nValid);
                for pi = 1:nValid
                    bb = bbs_scale(pi,:);
                    roi = I_scaled(bb(2):bb(4), bb(1):bb(3), :);
                    roiScale = imresize(roi, [64, 64], 'bilinear');
                    feat = hog(single(roiScale), 8, 9);
                    FD_scale(:, pi) = feat(:);
                end
                bbs(cnt:cnt+nValid-1, :) = bbs_scale;
                labels(cnt:cnt+nValid-1) = labels_scale;
                FD(:, cnt:cnt+nValid-1) = FD_scale;
                cnt = cnt + nValid;
            end
            bbs(cnt:end, :) = [];
            labels(cnt:end) = [];
            FD(:, cnt:end) = [];
            save(sprintf(VOCopts.hogtrainfdpath,ids{i}),'bbs','labels','FD');
        end
        nValid2 = size(bbs, 1);
        assert(size(labels, 2)==nValid2);
        assert(size(FD, 2)==nValid2);
        detector.bbox(counter:counter+nValid2-1, :) = bbs;
        detector.gt(counter:counter+nValid2-1) = labels;
        detector.FD(:, counter:counter+nValid2-1) = FD;
        counter = counter + nValid2;
    end
end
detector.bbox(counter:end, :) = [];
detector.gt(counter:end) = [];
detector.FD(:, counter:end) = [];

% svm cvx implementation
% voc_CVXSVM;

C = 10*nnz(detector.gt==1);
wPos = 1/nnz(detector.gt==1);
wNeg = 1/nnz(detector.gt==-1);
% scale data
maxRange = max(detector.FD, [], 2);
minRange = min(detector.FD, [], 2);
detector.midRange = (maxRange + minRange) / 2;
detector.range = maxRange - minRange;
FD_scaled = bsxfun(@rdivide, bsxfun(@minus, detector.FD, detector.midRange), detector.range/2);
detector.model = train(detector.gt',sparse(double(FD_scaled)),sprintf('-s 2 -c %f -B 1 -w1 %f -w-1 %f -q', C, wPos, wNeg),'col');

% tic;
% detector = hardNegMiningHOG(detector);
% toc
end