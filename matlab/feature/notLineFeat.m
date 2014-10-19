function feat = notLineFeat(X, centers, alpha)

d = dynamicDistanceSigmaCross(X, centers, alpha);
feat = exp(-10*d);

end