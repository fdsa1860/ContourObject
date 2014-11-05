function [result1, result2] = unitTest_resample

data = randn(1000,2);
data(:,1) = 1:1000;
fixedLength = 2;
mode = 1;
tic;result1 = resample(data,mode,fixedLength);toc
tic;result2 = resample_legacy(data,mode,fixedLength);toc
% result1
% result2

end

