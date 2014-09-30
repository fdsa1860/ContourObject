function feat = bowFeatHHSigmaAll(X_all_HH, centers_HH, X_all_sigma, centers_sigma, alpha)

nc = length(centers_HH);
numImg = length(X_all_HH);
feat = zeros(nc, numImg);
for i = 1:numImg
    if isempty(X_all_HH{i})
        feat(:,i) = zeros(nc,1);
    else
        feat(:,i) = bowFeatHHSigma(X_all_HH{i}, centers_HH, X_all_sigma{i}, centers_sigma, alpha);
    end
end

end