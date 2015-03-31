function [label,X_center,D] = ncutJLD(X,k,opt)
% ncutJLD:
% perform kmeans clustering on covariance matrices with JLD metric
% Input:
% X: an N-by-1 cell vector
% k: the number of clusters
% Output:
% label: the clustered labeling results

N = length(X);
D = zeros(N);
for i=1:N
    for j=i:N
        if strcmp(opt.metric,'JLD')
            HH1 = X{i};
            HH2 = X{j};
            D(j,i) = log(det((HH1+HH2)/2)) - 0.5*log(det(HH1*HH2));
        elseif strcmp(opt.metric,'binlong')
            D(j,i) = 2 - norm(X{i}+X{j},'fro');
        end
    end
end
D = D + D';
% load sD;
% D = sD;

W = exp(-D);
NcutDiscrete = ncutW(W, k);
label = sortLabel_count(NcutDiscrete);

X_center = cell(1, k);
for j=1:k
    if strcmp(opt.metric,'JLD')
        X_center{j} = karcher(X{label==j});
    elseif strcmp(opt.metric,'binlong')
        X_center{j} = findCenter(X(label==j));
    end
end

end

function center = findCenter(X)

n = length(X);
D = zeros(n,n);
for i=1:n
    for j=i+1:n
%         D(i,j) = hankeletAngle(X{i},X{j},thr);
        D(i,j) = 2 - norm(X{i}+X{j},'fro');
    end
end
D = D + D';
d = sum(D);
[~,ind] = min(d);
center = X{ind};

end