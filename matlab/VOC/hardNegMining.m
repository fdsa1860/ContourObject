function detector = hardNegMining(VOCopts, cls, detector)

OV_THRES = 0.5;
BBSNUM_MAX = 10;
nN_MAX = 100;

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
Dim = 14256;
N_MAX = 160000;
FD = zeros(Dim, N_MAX);
bbs = zeros(N_MAX, 4);
labels = zeros(1, N_MAX);
cnt = 1;
tic;
for i=1:length(ids)
% for i = 1
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
        % compute and save features
        interval = 1;
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
            
            bbs_neg = bbs_prop(labels_prop==-1, :);
            
            nN = min(nN_MAX, size(bbs_neg, 1));
            FD_scale = zeros(Dim, nN);
            for pi = 1:nN
                bb = bbs_neg(pi,:);
                roi = I_scaled(bb(2):bb(4), bb(1):bb(3), :);
                roiScale = imresize(roi, [64, 64], 'bilinear');
                feat = img2feat_fast(roiScale, 8);
                FD_scale(:, pi) = feat(:);
            end
            [~, ~, conf] = predict(ones(size(FD_scale, 2), 1), sparse(double(FD_scale)'), detector.model, '-q');
            [~, ind] = sort(-conf);
            nValid = min(BBSNUM_MAX, nN);
            bbs(cnt:cnt+nValid-1, :) = bbs_neg(ind(1:nValid), :);
            labels(cnt:cnt+nValid-1) = -ones(nValid, 1);
            FD(:, cnt:cnt+nValid-1) = FD_scale(:, ind(1:nValid));
            cnt = cnt + nValid;
        end
    end
end
bbs(cnt:end, :) = [];
labels(cnt:end) = [];
FD(:, cnt:end) = [];
nValid2 = size(bbs, 1);
detector.bbox = [detector.bbox; bbs];
detector.gt = [detector.gt, -ones(1, nValid2)];
detector.FD = [detector.FD, FD];

% detector.model = svmtrain(detector.gt',sparse(detector.FD'),'-t 0');
detector.model = train(detector.gt',sparse(double(detector.FD')),'-s 2');


end