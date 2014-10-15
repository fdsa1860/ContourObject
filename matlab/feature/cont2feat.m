function [feat, cont] = cont2feat(cont)

nBins = 9;
% build block
block = genBlock(cont.imgSize(2), cont.imgSize(1), 1, 4);
% nBlocks = size(block, 1);
% feat = zeros(nBlocks*nBins, 1);

% get slope
slope = slopeEst(cont.seg_line);
% structured hist of slope
if isempty(slope), return; end
feat = structureLineFeat(slope, nBins, cont.points_line, block);
feat = l2Normalization(feat);

cont.block = block;
cont.feat = feat;

end