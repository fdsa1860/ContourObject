function [x,y,gx,gy,pb] = comp_edgelet(img, para, ori_img, file_name, is_disp);
% [x,y,gx,gy,pb] = comp_edgelet(img, para, ori_img, file_name, is_disp);
% Compute edgels
% 
% INPUT
%   img       Image file name or image matrix.
%   para      Parameters for edge detection. 
%   ori_img   Original image.
%   file_name File name for precomputed pb.
%   is_disp   0/1. Display edgels or not.
% 
% OUTPUT
%   x         nx2 matrix. X positions of edgels. First column: integer 
%             number of coordinates. Second column: real number of
%             coordinates. Positions have benn duplicated (i.e. the first half and
%             the second half has the same positions).
%   y         nx2 matrix. Y positions of edgels. Description similar
%             to x. 
%   gx        nx1 vector. Edgel directions (cos(theta)). 
%   gy        nx1 vector. Edgel directions (sin(theta)). 
%   pb        matrix of pb (optional).
% 
% Qihui Zhu <qihuizhu@seas.upenn.edu>
% GRASP Lab, University of Pennsylvania
% 02/01/2010

% Read image if needed
if (ischar(img))
    img = imread(img);
end

if (isfield(para, 'is_subsample') && para.is_subsample)
    img2 = img;
    img = ori_img;
end

img = double(img);
if (max(img(:)) > 1)
    img = img / 255;
end

img_h = size(img, 1);
img_w = size(img, 2);

% Edge detection
if (size(img, 3) > 1)
    img_gray = rgb2gray(img);
end

pb = [];

% Using quadedge
if (~isfield(para, 'detector') || strcmp(para.detector, 'quad'))
    [x,y,gx,gy,par,threshold,mag,mage,g,FIe,FIo,mago] = ...
        quadedge_subpixel(img_gray, para.filter_par, para.pb_thres);
end

% Use pb or pb subpixel version
if (isfield(para, 'detector') && (strcmp(para.detector, 'pb') || strcmp(para.detector, 'pb_sub')))
    if (strcmp(para.detector, 'pb'))
        % Compute pb
        if (size(img, 3) > 1)
            [pb, theta] = pbCGTG(img);
        else
            [pb, theta] = pbBGTG(img);
        end
        [iy, ix] = find(pb > para.pb_thres);
        ind = iy+(ix-1)*img_h;
        x = [ix, ix];
        y = [iy, iy];
    else
        % Using pb subpixel
        if (size(img, 3) > 1)
            [pb, theta, px, py] = pbCGTG_subpixel(img);
        else
            [pb, theta, px, py] = pbBGTG_subpixel(img);
        end
        [iy, ix] = find(pb > para.pb_thres);
        ind = iy+(ix-1)*img_h;
        x = [ix, px(ind)];
        y = [iy, py(ind)];
    end
    gx = sin(theta(ind));
    gy = -cos(theta(ind));
end

% Load precomputed pb if exists
if (isfield(para, 'detector') && strcmp(para.detector, 'pb_pre'))
    if (isempty(file_name))
        error('File name missing?');
    end
    [pathstr, name, ext, versn] = fileparts(file_name);
    if (isfield(para, 'pb_dir') && ~isempty(para.pb_dir))
        pb_dir = para.pb_dir;
    else
        pb_dir = fullfile(bsdsRoot(), 'pb_res');
    end
    pb_file = fullfile(pb_dir, sprintf('%s_pb.mat', name));
    data = load(pb_file);
    [iy, ix] = find(data.pb_sub > para.pb_thres);
    ind = iy+(ix-1)*img_h;
    x = [ix, data.px(ind)];
    y = [iy, data.py(ind)];
    gx = sin(data.theta_sub(ind));
    gy = -cos(data.theta_sub(ind));
end

% Display edgels
if (nargin == 5 && is_disp > 0)
    figure;
    disp_fragments(x, y, gx, gy);
end
