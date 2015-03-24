function avgConsistency = dymEdgeCompare_batch(opt)

if nargin<1
    opt.dataDir = '~/research/code/ContourObject/expData/dymGroundTruth';
    opt.dataset = 'train';
    opt.binary = true;
end

%% get file name list
files = dir(fullfile(opt.dataDir,opt.dataset,'*.mat'));
nFile = length(files);
fileNameList = cell(1, nFile);
for i = 1:nFile
    fileNameList{i} = fullfile(opt.dataDir,opt.dataset,files(i).name);
end

%% compute consistency
avgConsistency = zeros(1, nFile);
tid = ticStatus('computing average consistency:');
for fid = 1:nFile
    load(fileNameList{fid});
    if opt.binary
        for i = 1:length(dymGroundTruth)
            dymGroundTruth{i}.dymBoundaries = double(dymGroundTruth{i}.dymBoundaries~=0);
        end
    end
    
    n = length(dymGroundTruth);
    accMat = zeros(n,n);
    for i = 1:n
        for j = 1:n
            accMat(i,j) = dymEdgeCompare(dymGroundTruth{i}.dymBoundaries, dymGroundTruth{j}.dymBoundaries);
        end
    end
    
    T = triu(accMat,1);
    avgConsistency(fid) = sum(T(:))/nnz(T);
    tocStatus(tid, fid/nFile);
end
% imagesc(accMat);

save ~/research/code/ContourObject/expData/avgConsistency avgConsistency;

end