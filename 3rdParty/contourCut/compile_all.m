% Compile all mex files
% 
% Qihui Zhu <qihuizhu@seas.upenn.edu>
% GRASP Lab, University of Pennsylvania
% 02/02/2010

startup

% Find out the current Matlab version
str = version();
A = sscanf(str, '%d.%d.%s');
if (A(1)>=7 && A(2)>=3)
    % Version 7.3 or later
    is_2006b = 1;
else
    is_2006b = 0;
end

mex_dir('mex', is_2006b);

% Compile normalized cut
if exist('Ncut_9', 'dir')
    cd Ncut_9
    compileDir_simple;
    cd ..;
end
