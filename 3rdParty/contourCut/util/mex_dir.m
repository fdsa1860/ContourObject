function mex_dir(src_dir, is_2006b)
% mex_dir(src_dir, is_2006b);

old_dir = pwd;
try
    cd(src_dir);
catch
    fprintf('Error: %s', lasterr);
    cd(old_dir);
end

if (nargin == 2 && is_2006b)
    flag = '-largeArrayDims';
else
    flag = '';
end

file_list = dir('*.*');
for ii = 1:length(file_list)
    [pathstr, name, ext] = fileparts(file_list(ii).name);
    if (strcmp(ext, '.c') || strcmp(ext, '.cpp'))
        fprintf('Mex %s...', file_list(ii).name);
        cmd = sprintf('mex %s %s', flag, file_list(ii).name);
        eval(cmd);
        fprintf('Done.\n');
    end
end

cd(old_dir);
