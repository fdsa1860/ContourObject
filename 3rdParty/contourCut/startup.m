function startup(rootpath)
% startup(rootpath)

if (~exist('rootpath'))
    rootpath = cd;
end

addpath(genpath(rootpath));
