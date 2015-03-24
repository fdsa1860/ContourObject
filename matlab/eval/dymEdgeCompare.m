function [accFinal, acc, nMatch, nTotal] = dymEdgeCompare(E1, E2)

label1 = unique(E1);
label2 = unique(E2);
label = unique([label1;label2]);
label = label(label~=0);

nMatch = zeros(length(label), 1);
nTotal = zeros(length(label), 1);
acc = zeros(length(label), 1);
for i = 1:length(label)
    bmap1 = double(E1==label(i));
    bmap2 = double(E2==label(i));
    [match1,match2] = correspondPixels(bmap1, bmap2);
    nMatch(i) = nnz(match1)+nnz(match2);
    nTotal(i) = nnz(bmap1)+nnz(bmap2);
    acc(i) = nMatch(i)/nTotal(i);
end

accFinal = sum(nMatch)/sum(nTotal);

end