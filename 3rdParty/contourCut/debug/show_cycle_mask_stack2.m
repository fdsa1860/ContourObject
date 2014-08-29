function [img_stack, loop2frame] = show_cycle_mask_stack2(pixel_order, x, y, img_sz, to_disp);
% [img_stack, loop2frame] = show_cycle_mask_stack2(pixel_order, x, y, img_sz, to_disp);

% This version only requires pixel_order

if (nargin < 5)
    to_disp = 1;
end

x = x(:, 1);
y = y(:, 1);
imgh = img_sz(1);
imgw = img_sz(2);

n = length(pixel_order);
nb_remain = n;
nb_frames = 0;
nb_pts = length(x);
ii = 0;
sj = zeros(n, 1);
cid = 0;

% Fill in frame indices
while (nb_remain > 0)
    ii = mod(ii, n)+1;
    if (ii == 1)
        % Start a new frame
        is_used = zeros(nb_pts, 1);
        nb_frames = nb_frames + 1;
        if (cid > 0)
            img_stack{nb_frames-1} = sparse(iy, ix, val, imgh, imgw);
        end
        cid = 1;
        ix = [];
        iy = [];
        val = [];
    end
    if (sj(ii) > 0)
        continue;
    end
    pid = pixel_order{ii};
    if (sum(is_used(pid)) == 0)
        % Record the loop
        is_used(pid) = 1;
        sj(ii) = nb_frames;
        nb_remain = nb_remain-1;
        ix = [ix; x(pid)];
        iy = [iy; y(pid)];
        val = [val; ones(length(pid), 1)*cid];
        cid = cid + 1;
    end
end
img_stack{nb_frames} = sparse(iy, ix, val, imgh, imgw);

loop2frame = sparse(1:n, sj, 1, n, nb_frames);

