% compile mex files on OS X system

inputDir = '../mex';
inputFiles = dir(fullfile(inputDir,'*.cpp'));
outputDir = '../mex';
cmd = 'mex';
% option = ' -largeArrayDims ';
option = '';
for i = 1:length(inputFiles)
    cmd = sprintf('mex %s %s -outdir %s',option, fullfile(inputDir,inputFiles(i).name), outputDir);
    eval(cmd);
end