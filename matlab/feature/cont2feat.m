function [feat, cont] = cont2feat(cont, centers, bbox)

if isempty(centers)
    feat = [];
    return;
end

if nargin < 3
    bbox = [1 1 cont.imgSize(2) cont.imgSize(1)];
end

nBins = 9;
% build block
block = genBlock(bbox, 4, 16);
% nBlocks = size(block, 1);
% feat = zeros(nBlocks*nBins, 1);

% get slope
slope = slopeEst(cont.seg_line);
% structured hist of slope
% if isempty(slope), return; end
featLine = structureLineFeat(slope, nBins, cont.points_line, block);
featLine = l2Normalization(featLine);

% build hankel matrix
hankel_size = 4;
mode = 1;
numSeg = length(cont.dscA_notLine);
dscaNotLine_data(1:numSeg) = struct('dsca',[], 'H',[], 'HH',[]);
for i = 1:numSeg
    [dscaNotLine_data(i).H, dscaNotLine_data(i).HH] = buildHankel(cont.dscA_notLine{i}, hankel_size, mode);
    dscaNotLine_data(i).dsca = cont.dscA_notLine{i};
end
% normalized singular value estimation
try
    dscaNotLine_data = sigmaEst(dscaNotLine_data);
catch
    keyboard;
end
% structured non-line feature
alpha = 0;
featNotLine = structureBowFeatHHSigma(dscaNotLine_data, centers, alpha, cont.points_notLine, block);
featNotLine = l2Normalization(featNotLine);

feat = [featLine; featNotLine];
cont.block = block;
cont.feat = feat;

end