function cont_pts = extract_contour_pts(fname, is_long);
% cont_pts = extract_contour_pts(fname, is_long);

if (ischar(fname))
    warning off;
    fname = load(fname, 'x', 'y', 'gx', 'gy', 'res_info', 'pixel_order');
    warning on;
end
if (nargin < 2)
    is_long = 0;
end

if (is_long)
    pixel_order = fname.pixel_order;
else
    pixel_order = fname.res_info.pixel_order;
end
x = fname.x(:, 1);
y = fname.y(:, 1);
gx = fname.gx;
gy = fname.gy;

n = length(pixel_order);
cont_pts = cell(1, n);
for ii = 1:n
    cont_pts{ii} = [x(pixel_order{ii})'; y(pixel_order{ii})'; ...
        atan2(-gx(pixel_order{ii}), gy(pixel_order{ii}))'];
end
