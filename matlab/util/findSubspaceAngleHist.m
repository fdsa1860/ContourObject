function h = findSubspaceAngleHist(centers, samples, normalize)

k = length(centers);
n = length(samples);
D = zeros(k,n);
thr = 0.99;
for i = 1:n
    for j = 1:k
        D(j,i) = mySubspaceAngle(samples{i},centers{j},thr);
    end
end
[~,ind] = min(D);
h = hist(ind,1:k);

if normalize
    h = h/sum(h);
end

end