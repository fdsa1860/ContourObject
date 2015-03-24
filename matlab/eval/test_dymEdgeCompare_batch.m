% % get average consistency scores
opt.dataDir = '~/research/code/ContourObject/expData/dymGroundTruth';

opt.dataset = 'train';
opt.binary = false;
avgConsistency = dymEdgeCompare_batch(opt);
% save avgConsistency_bsds_train_SW_h7_HHt_s3_w30 avgConsistency;
save avgConsistency_bsds_train_MS_h10_HHt_w30 avgConsistency;

% opt.dataset = 'test';
% opt.binary = false;
% avgConsistency = dymEdgeCompare_batch(opt);
% save avgConsistency_bsds_test_MS_h10_s5_w30 avgConsistency;

% opt.dataDir = '~/research/data/BSR/BSDS500/data/groundTruth';
% 
% opt.dataset = 'train';
% avgConsistency = edgeCompare_batch(opt);
% save avgConsistency_bsds_train_groundTruth avgConsistency;
% 
% opt.dataset = 'test';
% avgConsistency = edgeCompare_batch(opt);
% save avgConsistency_bsds_test_groundTruth avgConsistency;