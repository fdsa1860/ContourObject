function [x2, y2, gx2, gy2, idx] = prune_border(x, y, gx, gy, imgsz);
% [x2, y2, gx2, gy2, idx] = prune_border(x, y, gx, gy, imgsz);

margin = 4;
thres = 0.98;

theta = atan2(gy, gx);

idx1 = find((x(:, 1)<=margin | x(:, 1)>=imgsz(2)-margin+1) & abs(cos(theta))>thres);
idx2 = find((y(:, 1)<=margin | y(:, 1)>=imgsz(1)-margin+1) & abs(sin(theta))>thres);
idx = 1:length(x);
idx([idx1; idx2]) = [];
x2 = x(idx, :);
y2 = y(idx, :);
gx2 = gx(idx);
gy2 = gy(idx);
