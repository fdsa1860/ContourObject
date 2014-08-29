function h = disp_fragments(x,y,gx,gy,offset);

if (nargin == 1 && isstruct(x))
    y = x.y;
    gx = x.gx;
    gy = x.gy;
    x = x.x;
end
if (nargin < 5)
    offset = 0;
end

% % For subpixel precision
% if (size(x, 2) == 1)
%     x = [x, zeros(size(x))];
%     y = [y, zeros(size(y))];
% else
%     % Adjust for display
%     x(:,2) = x(:,2)-0.5;
%     y(:,2) = y(:,2)-0.5;
% end
if (size(x, 2) == 1)
    x = [x, x];
    y = [y, y];
end


border = 5;
arrow_scale = 0.5;

x1 = x(:,1);
y1 = y(:,1);
x_offset = 0;
y_offset = 0;
img_h = max(y1);
img_w = max(x1);
% min_x1 = min(x1);
% min_y1 = min(y1);
% img_h = round(max(y1)-min_y1)+1+border*2;
% img_w = round(max(x1)-min_x1)+1+border*2;
% x1 = round(x1-min_x1)+1+border;
% y1 = round(y1-min_y1)+1+border;
% x_offset = -min_x1+1+border;
% y_offset = -min_y1+1+border;


h = imagesc(sparse(y1, x1, 1, img_h, img_w)>0); 
axis image; 
axis ij; 
hold on;
quiver(x(:,2)+x_offset+offset, y(:,2)+y_offset+offset, gy, -gx, arrow_scale, 'g');
hold off;
colormap gray;
