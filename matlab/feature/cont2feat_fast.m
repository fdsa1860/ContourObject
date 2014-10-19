function [feat, cont] = cont2feat_fast(cont, centers, bbs)

if isempty(centers)
    feat = [];
    return;
end

if nargin < 3
    bbs = [1 1 cont.imgSize(2) cont.imgSize(1)];
end

nBins = 9;
nc = length(centers);
gridRows = 16;
gridCols = 4;
nBlocks = gridRows * gridCols;
feat = zeros((nBins+nc) * nBlocks, size(bbs, 1));


numLine = length(cont.dscA_line);
numNotLine = length(cont.dscA_notLine);
numSeg = numLine + numNotLine;
featLen = nBins + nc;
seg(1:numSeg) = struct('isLine',false, 'points',[0 0],  ...
    'feat',zeros(featLen, 1));
slope = slopeEst(cont.seg_line);
for i = 1:numLine
    [tmpFeat, ind] = lineFeat(slope(i), nBins);
    seg(i).feat = [tmpFeat'; zeros(nc, 1)];
    seg(i).isLine = true;
    seg(i).points = cont.points_line(i, :);
    seg(i).featLen = nBins + nc;
    seg(i).lineFeatInd = [true(nBins, 1); false(nc, 1)];
    seg(i).notLineFeatInd = [false(nBins, 1); true(nc, 1)];
end

alpha = 0;
% build hankel matrix
hankel_size = 4;
mode = 1;
dscaNotLine_data(1:numNotLine) = struct('dsca',[], 'H',[], 'HH',[]);
for i = 1:numNotLine
    [dscaNotLine_data(i).H, dscaNotLine_data(i).HH] = buildHankel(cont.dscA_notLine{i}, hankel_size, mode);
    dscaNotLine_data(i).dsca = cont.dscA_notLine{i};
end
% normalized singular value estimation
dscaNotLine_data = sigmaEst(dscaNotLine_data);
% notLine feature
for i = 1:numNotLine
    [tmpFeat] = notLineFeat(dscaNotLine_data(i), centers, alpha);
    seg(numLine+i).feat = [zeros(nBins, 1); tmpFeat'];
    seg(numLine+i).isLine = false;
    seg(numLine+i).points = cont.points_notLine(i, :);
    seg(numLine+i).featLen = nBins + nc;
    seg(numLine+i).lineFeatInd = [true(nBins, 1); false(nc, 1)];
    seg(numLine+i).notLineFeatInd = [false(nBins, 1); true(nc, 1)];
end

for i = 1:size(bbs, 1)
    bbox = bbs(i, 1:4);
    block = genBlock(bbox, gridCols, gridRows);
    feat(:, i) = structureFeat(seg, block);
end

% cont.block = block;
% cont.feat = feat;

end