function [x y gx gy s2p] = compressW(W_orig, x_orig, y_orig, gx_orig, gy_orig, imgh, imgw, pb_theta, nb_clusters)


Wclust = max(W_orig,W_orig');
Wclust = Wclust(1:end/2, 1:end/2);
[NcutDiscrete,NcutEigenvectors,NcutEigenvalues] = ncutW(Wclust,nb_clusters);

[junk ci] = max(NcutDiscrete,[],2);
fragments = {};
gxfrag = [];
gyfrag = [];
xfrag = [];
yfrag = [];
% Make sure each cluster is at least pretty well connected
s2p = sparse(size(W_orig,1), size(W_orig,1)/2);
numfrags = 0;
for i = 1:max(ci)
    ind = find(ci==i);
    if numel(ind) == 0
        continue;
    end
    if numel(ind) > 1
        %split into connected components
        [c s] = components(Wclust(ind,ind)>0.3);
    else
        c = 1;
        s = 1;
    end
    for j = 1:numel(s)
        fragments = [fragments; [x_orig(ind(c==j),1) y_orig(ind(c==j),1)]];
        gxfrag = [gxfrag; median(gx_orig(ind(c==j),1), 1)];
        gyfrag = [gyfrag; median(gy_orig(ind(c==j),1), 1)];
        xfrag = [xfrag; round(median(x_orig(ind(c==j),1),1)) median(x_orig(ind(c==j),1), 1)];
        yfrag = [yfrag; round(median(y_orig(ind(c==j),1),1)) median(y_orig(ind(c==j),1), 1)];
        numfrags = numfrags+1;
        s2p(numfrags, ind(c==j))=1;
    end
end
s2p = s2p(1:numfrags,:);
s2p = [s2p sparse(size(s2p,1), size(s2p,2)); sparse(size(s2p,1), size(s2p,2)) s2p];



locs = vertcat(fragments{:});
x = round(locs(:,1));
y = round(locs(:,2));
x(x==0) = 1;
y(y==0) = 1;
x(x>imgw) = imgw;
y(y>imgh) = imgh;
ind = sub2ind(size(pb_theta), y, x);
gx = sin(pb_theta(ind));
gy = -cos(pb_theta(ind));
