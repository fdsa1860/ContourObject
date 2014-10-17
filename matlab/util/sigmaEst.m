function seg = sigmaEst(seg)
% Input:
% seg.H: 1 by N cell array, each cell contains a hankel matrix
% Output:
% seg.sigma: D by N matrix, each column contains normalize singular value
% vector

if isempty(seg)
    seg().sigma = [];
    return;
end

numSeg = length(seg);
for i = 1:numSeg
    s = svd(seg(i).H);
    seg(i).sigma = s./s(1);
end

end