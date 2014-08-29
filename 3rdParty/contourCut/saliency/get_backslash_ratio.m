function r = get_backslash_ratio(x, y, gx, gy, img_sz, para_w, W);
% r = get_backslash_ratio(x, y, gx, gy, img_sz, para_w, W);
% Compute backslash ratio, i.e. how much flow is bounced back
% 
% INPUT
%   x,y,gx,gy   Edge point output from comp_edgelet.m.
%   img_sz      Image size [height, width].
%   para_w      Parameters for graph weights (para{4}). 
%   W           Weight matrix without backslash.
% OUTPUT
%   r           Ratio of returning flow at each edge point.
%               length(r)==size(W, 1)
% 
% Qihui Zhu <qihuizhu@seas.upenn.edu>
% GRASP Lab, University of Pennsylvania
% 02/08/2010


nb_pix = length(x);
imgh = img_sz(1);
imgw = img_sz(2);

% Note: [gx, gy] is normal
[si, sj] = mex_get_paths(x(:, 1), y(:, 1), gx, gy, img_sz, para_w.nb_r);

% Ratio
W_deg = sparse(sj, si, 1, nb_pix, 2*nb_pix);
W2 = (W(:, 1:end/2)+W(:, end/2+1:end))';
deg = full(sum(W_deg))';
ratio = full(sum(W_deg.*W2)./(sum(W2)+eps))';

min_deg = max(3, round(para_w.nb_r/2));
max_r = 0.95;
min_r = 0.7;
r = (deg<min_deg)+(deg>=min_deg).*min(max((max_r-ratio)/(max_r-min_r), 0), 1);

