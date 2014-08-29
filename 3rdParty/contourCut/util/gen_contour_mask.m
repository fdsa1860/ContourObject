function [cmask,px,py] = gen_contour_mask(pixel_order, x, y, img_sz);
% [cmask,px,py] = gen_contour_mask(pixel_order, x, y, img_sz);

x = x(:);
y = y(:);

if (exist('img_sz', 'var'))
    imgh = img_sz(1);
    imgw = img_sz(2);
else
    imgh = ceil(max(y));
    imgw = ceil(max(x));
end

if (length(pixel_order) == 1)
    px = x(pixel_order{1});
    py = y(pixel_order{1});
    cmask = double(sparse(round(py), round(px), 1, imgh, imgw)>0);
else
    si = [];
    sj = [];
    for ii = 1:length(pixel_order)
        si = [si; y(pixel_order{ii})];
        sj = [sj; x(pixel_order{ii})];
    end
    cmask = double(sparse(round(si), round(sj), 1, imgh, imgw)>0);
    [py, px] = find(cmask);
end

if (nargout == 0)
    imagesc(full(cmask));
    colormap(gray);
    axis image;
end
