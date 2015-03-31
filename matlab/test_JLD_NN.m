% sythetic test

addpath(genpath('../matlab'));
addpath(genpath('../3rdParty'));

opt.metric = 'JLD';
% opt.metric = 'binlong';

r(1, :) = [1 -0.3 0.3 ];
r(2, :) = [0.5 -0.3 0.8];
r(3, :) = [0.7 -0.2 0.5];
r(4, :) = [0.7 0.2 0.1];

rng('default');
n = 1000;
d = 20;
N = n*size(r, 1);
trainData = zeros(d, N);
trainData(1:3, :) = randn(3, N);
for i = 1:size(r,1)
    ind = (i-1)*n+1:i*n;
    for j = 4:d
        trainData(j,ind) = r(i,:) * trainData(j-3:j-1,ind);
    end
end
% trainData = trainData + 0.1*randn(d, N);
trainNorm = sum(trainData.^2);
trainData = bsxfun(@rdivide, trainData, trainNorm);
trainData = trainData + 0.001*randn(d, N);

testData = zeros(d, N);
testData(1:3, :) = randn(3, N);
for i = 1:size(r,1)
    ind = (i-1)*n+1:i*n;
    for j = 4:d
        testData(j,ind) = r(i,:) * testData(j-3:j-1,ind);
    end
end
% testData = testData + 0.1*randn(d, N);
testNorm = sum(testData.^2);
testData = bsxfun(@rdivide, testData, testNorm);
testData = testData + 0.01*randn(d, N);

%% training
nc = 4;
HH = cell(1,N);
for i = 1:N
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
HH_centers = cell(1, size(r,1));
for i = 1:size(r,1)
    HH_centers{i} = karcher(HH{(i-1)*n+1:i*n});
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
HH_test = cell(1,N);
for i = 1:N
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
D = zeros(length(HH_centers),N);
for i = 1:N
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
gt = kron([1 2 3 4],ones(1,n));
v = perms(1:size(r,1));
acc = zeros(1,size(v,1));
for i = 1:length(acc)
    acc(i) = nnz(v(i,label)==gt)/length(gt);
end
[precision,ind] = max(acc);
precision
label = v(ind,label);

M = confusionmat(gt,label)/n;

%% display
plotConfusionMatrix(M);
xlabel('predicted labels');
ylabel('groundtruth');
