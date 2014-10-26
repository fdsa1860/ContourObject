function [centers, sLabel, sD] = vocClsfCluster(dscaNotLineAll)

load ../expData/voc_dsca_notLine_sD_a0_h4_20141023

% build hankel matrix
hankel_size = 4;
dscaNotLineAll_data = buildHankelAll(dscaNotLineAll, hankel_size, 1, true);
% normalized singular value estimation
dscaNotLineAll_data = sigmaEstAll(dscaNotLineAll_data, true);
% pooling
poolMaxSize = 50000;
dscaNotLinePool = pooling(dscaNotLineAll_data, poolMaxSize);
% computer cluster centers
nc = 10; alpha = 0;
tic;
[centers, sLabel, sD] = nCutContourHHSigma(dscaNotLinePool(1:10000), nc, alpha, sD);
toc
% if length(unique(sLabel))>=10
%     centers = centers(1:10);
% end

% save voc_dsca_notLine_sD_a0_h4_sig005_20141023 sD;
% centersFileName = 'voc_dsca_notLine_centers_w10_a0_h4_sig001_20141023';
% save(centersFileName, 'centers', 'sLabel');
% load ../expData/voc_dsca_notLine_centers_w10_a0_h4_20141016

end