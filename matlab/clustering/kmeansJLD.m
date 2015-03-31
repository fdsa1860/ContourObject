function [label,X_center,D] = kmeansJLD(X,k,opt)
% kmeansJLD:
% perform kmeans clustering on covariance matrices with JLD metric
% Input:
% X: an N-by-1 cell vector
% k: the number of clusters
% Output:
% label: the clustered labeling results

N = length(X);
D = zeros(k,N);
ind = randsample(N,k);
X_center = X(ind);
label = ones(1,N);
label_old = zeros(1,N);

iter = 0;
iter_max = 100;
while iter<iter_max && nnz(label-label_old)~=0
    
    for i=1:N
        for j=1:k
            if strcmp(opt.metric,'JLD')
                HH1 = X{i};
                HH2 = X_center{j};
                D(j,i) = log(det((HH1+HH2)/2)) - 0.5*log(det(HH1*HH2));
            elseif strcmp(opt.metric,'binlong')
                D(j,i) = 2 - norm(X{i}+X_center{j},'fro');
            end
        end
    end
    label_old = label;
    [~,label] = min(D);
    for j=1:k
        if strcmp(opt.metric,'JLD')
            X_center{j} = karcher(X{label==j});
        elseif strcmp(opt.metric,'binlong')
            X_center{j} = findCenter(X(label==j));
        end
    end
    iter = iter + 1;
    
end

if iter==iter_max
    warning('kmeans has reached maximum iterations before converging.\n');
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