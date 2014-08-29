function select_contour_conf(pixel_order, x, y, img_sz, gx, gy, sel_file);
% select_contour_conf(pixel_order, x, y, img_sz, gx, gy, sel_file);
% Display different contours for debugging
% 
% Qihui Zhu <qihuizhu@seas.upenn.edu>
% GRASP Lab, University of Pennsylvania
% 02/02/2010


if (ischar(pixel_order))
    pixel_order = load(pixel_order);
end
if (isstruct(pixel_order))
    x = pixel_order.x;
    y = pixel_order.y;
    img_sz = [pixel_order.imgh, pixel_order.imgw];
    if (isfield(pixel_order, 'pixel_order'))
        % Old format
        pixel_order = pixel_order.pixel_order;
    else
        pixel_order = pixel_order.res_info.pixel_order;
    end
end

x = x(:, 1);
y = y(:, 1);
x = [x;x];
y = [y;y];
imgh = img_sz(1);
imgw = img_sz(2);

img_edge = sparse(y(1:end/2), x(1:end/2), 1, img_sz(1), img_sz(2));
img_edge = min(img_edge, 1);
cont_map = gen_contour_mask(pixel_order, x, y,img_sz);
img_edge = img_edge + cont_map;
[img_stack, loop2frame] = show_cycle_mask_stack2(pixel_order, x, y, img_sz);

frame_id = 1;
nb_frames = size(loop2frame, 2);

% Display
figure;
ax1 = subplot('Position', [0.05,0.03,0.9,1]);
imagesc(img_edge+img_stack{frame_id});
max_color = full(max(img_stack{frame_id}(:)));
c =  hsv(max_color);
c = c(randperm(size(c,1)), :);
cmap = [0,0,0; 0.3,0.3,0.3; 1,1,1; c];
colormap(cmap);
axis image;
hold on;
title(sprintf('Frame %d', frame_id));

h = gcf;
set(h, 'Name', 'Left-click to select. Right-click to view the next page');
set(h, 'WindowButtonDownFcn', @callback_click);
to_delete = [];
contour_id = -1;
pt_id = -1;
xsc = zeros(length(pixel_order), 1);

% Internal callback function
    function callback_click(src, event);

        pt = get(gca, 'CurrentPoint');

        selectionType = get(gcf, 'SelectionType');

        if (ax1~=gca)
            return;
        end

        % For model pt selection
        if (strcmp(selectionType, 'normal'))
            delete(to_delete);

            % Selected point
            [iy, ix] = find(img_stack{frame_id});
            [dummy, id] = min((ix-pt(1,1)).^2+(iy-pt(1,2)).^2);
            sx = ix(id);
            sy = iy(id);

            % Find out which loop
            kk = img_stack{frame_id}(sy, sx);
            idx = find(loop2frame(:, frame_id));
            loop_id = idx(kk);
            contour_id = loop_id;

            subplot('Position', [0.05,0.03,0.9,1]);
            hold on;
            h2 = plot(x(pixel_order{contour_id}), y(pixel_order{contour_id}), 'gs', 'MarkerSize', 6);
            h1 = plot(sx, sy, 'r*', 'MarkerSize', 10, 'LineWidth', 2);
            title(sprintf('Frame %d: contour id=%d, [x,y]=[%d,%d]', ...
                frame_id, contour_id, sx, sy));

            to_delete = [h1; h2];

        end
        if (strcmp(selectionType, 'alt'))
            clf;
            to_delete = [];
            frame_id = mod(frame_id, nb_frames) + 1;
            model_id = -1;

            % Display
            ax1 = subplot('Position', [0.05,0.03,0.9,1]);
            imagesc(img_edge+img_stack{frame_id});
            max_color = full(max(img_stack{frame_id}(:)));
            c =  hsv(max_color);
            c = c(randperm(size(c,1)), :);
            cmap = [0,0,0; 0.3,0.3,0.3; 1,1,1; c];
            colormap(cmap);
            axis image;
            hold on;
            title(sprintf('Frame %d', frame_id));
            contour_id = -1;
        end
    end

end
