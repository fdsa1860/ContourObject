function feat = contourCode2feat(img, m)

X = [];
contour = img.cont;
nCont = length(contour);
for i = 1:nCont
    inds = contour(i).inds;
    if length(inds) < m, continue; end
    X = [X hankel(inds(1:m), inds(m:end))];
end

k = length(img.centers) + img.opt.nBins;
K = zeros(k*ones(1,m));
for i = 1:size(X, 2)
    ind1 = 1;
    ind2 = 1;
    for j = 1:m
        ind1 = ind1 + (X(j,i)-1) * k^(j-1);
        ind2 = ind2 + (X(j,i)-1) * k^(m-j);
    end
    K(ind1) = K(ind1) + 1;
    K(ind2) = K(ind2) + 1;
end

% take the upper triangle of K and vectorize it
if m==2
    feat = K(triu(true(size(K))));
elseif m==3
    ind = (1:k)';
    d1 = kron(ind, ones(k^(m-1), 1));
    d2 = kron(ind, ones(k^(m-2), 1));
    d2 = kron(ones(k, 1), d2);
    d3 = kron(ones(k^(m-1), 1), ind);
    isValid = d1<=d2 & d1<=d3 & d2<=d3;
    feat = K(isValid);
end

end