function disp_cont_pts(img, cont, color, sz);
% disp_cont_pts(img, cont, color, sz);
% Display contour points
% 
% Qihui Zhu <qihuizhu@seas.upenn.edu>
% GRASP Lab, University of Pennsylvania
% 02/06/2010


if (nargin < 3)
    color = [0, 0, 0];
end
if (nargin < 4)
    sz = 4;
end
alpha = 0.9;

if (max(img(:)) > 1)
    img = double(img)/255;
end
imshow(img*alpha+(1-alpha));
hold on;
for ii = 1:length(cont)
    plot(cont{ii}(1, :), cont{ii}(2, :), 'o', 'Color', color, 'MarkerFaceColor', color, ...
        'MarkerSize', sz);
end
