function W = compute_W(x, y, gx, gy, imgh, imgw, img, para);
% W = compute_W(x, y, gx, gy, imgh, imgw, img, para);
% Compute weight matrix W
% 
% INPUT
%   x     nx2 matrix. X positions. See output of comp_edgelet.m
%   y     nx2 matrix. Y positions.
%   gx    nx1 vector. Edgel directions.
%   gy    nx1 vector. Edgel directions.
%   imgh  A number of image height.
%   imgw  A number of image width.
%   img   Image matrix.
%   para  Parameters for computing W (para_w).
% 
% OUTPUT
%   W     nxn sparse matrix. Weights before normalization.
% 
% Qihui Zhu <qihuizhu@seas.upenn.edu>
% GRASP Lab, University of Pennsylvania
% 08/07/2007

[wa, wb, wc, wd] = mex_get_weight_dual2(x,y,gx,gy, [imgh, imgw], ...
    para.nb_r, para.sigma_e, para.bending, para.bounce_ratio);

% Compute backslash weights to detect open contours
if (isfield(para, 'no_backslash') && para.no_backslash > 0)
    % In mex files, wa/wb/wc/wd are stored in columun-first order    
    W = [wa', wb'; wc', wd'];
    back_r = get_backslash_ratio(x, y, gx, gy, [imgh, imgw], para, W);
    W_back = spmtimesd([wb, wa; wd, wc], back_r * para.bounce_ratio, []);
    
    U = [sparse(size(wa,1), size(wa,2)) speye(size(wa));
    speye(size(wa)) sparse(size(wa,1), size(wa,2))];


    W = W + U*para.bounce_ratio;
else
    U = [sparse(size(wa,1), size(wa,2)) speye(size(wa));
    speye(size(wa)) sparse(size(wa,1), size(wa,2))];

    W = [wa', wb'; wc', wd'] + U*para.bounce_ratio;
end

% Diffuse to nearest neighbors
if (para.diffuse_ratio > 0)
    % Simple kNN without a KD tree
    idx_knn = mex_knn_2d([x(:, 2),y(:, 2)], [x(:, 2),y(:, 2)], para.nb_neighbors);
    idx = idx_knn(1:para.w_sample_rate:end, :);
    
    [wa, wb, wc, wd] = mex_get_weight_dual_knn(x(:,2),y(:,2),gx,gy,[imgh, imgw], ...
        idx, para.sigma_e, para.bending, 0);
    W_knn = [wa', wb'; wc', wd'];
    
    W = W+W_knn*para.diffuse_ratio;
end

