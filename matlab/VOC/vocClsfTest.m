% run classifier on test images
function vocClsfTest(VOCopts,cls,classifier,centers)

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
