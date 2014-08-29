function r = findRank(seg,thres)

H = hankel_mo(seg);
s = svd(H);
r = find(cumsum(s)/sum(s)>thres,1);

end