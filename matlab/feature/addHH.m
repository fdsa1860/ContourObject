function seg = addHH(seg)

if isempty(seg), seg().H = []; seg().HH = []; return; end
numSeg = length(seg);
for i = 1:numSeg
    % H = hankel_mo(seg(i).vel');
    H = mexHankel(seg(i).vel');
    HH = (H * H') / norm (H * H', 'fro');
    seg(i).H = H;
    seg(i).HH = HH;
end

end