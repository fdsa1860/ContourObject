% sythetic test

addpath(genpath('../matlab'));
addpath(genpath('../3rdParty'));

rng('default');
data_generation;
n = 500;
d = num_frame;
N = n * num_sys;

data = data + randn(size(data));

trainData = [];
testData = [];
for i = 1:num_sys
    trainData = [trainData data(index_train(:,1)+(i-1)*n,:)'];
    testData = [testData data(index_test(:,1)+(i-1)*n,:)'];
end

opt.metric = 'JLD';
% opt.metric = 'binlong';

%% training
nc = 4;
HH = cell(1,size(trainData,2));
for i = 1:size(trainData,2)
    H1 = hankel_mo(trainData(:,i)',[d-nc+1, nc]);
    H1_p = H1 / (norm(H1*H1','fro')^0.5);
    HH1 = H1_p' * H1_p;
    if strcmp(opt.metric,'JLD')
        HH{i} = HH1 + 1e-6 * eye(nc);
%         HH{i} = HH1;
    elseif strcmp(opt.metric,'binlong')
        HH{i} = HH1;
    end
end

% NN
tic;
HH_centers = cell(1, num_sys);
for i = 1:num_sys
    HH_centers{i} = karcher(HH{(i-1)*size(index_train,1)+1:i*size(index_train,1)});
end
toc;

% % NN, binlong's metric
% centerInd = findCenters(sD, kron([1 2 3 4],ones(1,n)));
% HH_centers = HH(centerInd);

% % kmeans
% tic;
% [lb,HH_centers] = kmeansJLD(HH,4,opt);
% toc

% % ncut
% tic;
% [lb,HH_centers,sD] = ncutJLD(HH,4,opt);
% toc

%% testing
HH_test = cell(1,size(testData,2));
for i = 1:size(testData,2)
    H1 = hankel_mo(testData(:,i)',[d-nc+1, nc]);
    H1_p = H1 / (norm(H1*H1','fro')^0.5);
    HH1 = H1_p' * H1_p;
    if strcmp(opt.metric,'JLD')
        HH_test{i} = HH1 + 1e-6 * eye(nc);
    elseif strcmp(opt.metric,'binlong')
        HH_test{i} = HH1;
    end
end

tic
D = zeros(length(HH_centers),size(testData,2));
for i = 1:size(testData,2)
    for j = 1:length(HH_centers)
        if strcmp(opt.metric,'JLD')
            HH1 = HH_test{i};
            HH2 = HH_centers{j};
            D(j,i) = log(det((HH1+HH2)/2)) - 0.5*log(det(HH1*HH2));
        elseif strcmp(opt.metric,'binlong')
            D(j,i) = 2 - norm(HH_test{i}+HH_centers{j},'fro');
        end
    end
end
toc

[~,label] = min(D);

%% eval
gt = kron(1:num_sys,ones(1,unit_test));
v = perms(1:num_sys);
acc = zeros(1,size(v,1));
for i = 1:length(acc)
    acc(i) = nnz(v(i,label)==gt)/length(gt);
end
[precision,ind] = max(acc);
precision
label = v(ind,label);

M = confusionmat(gt,label)/unit_test;

%% display
plotConfusionMatrix(M);
xlabel('predicted labels');
ylabel('groundtruth');
