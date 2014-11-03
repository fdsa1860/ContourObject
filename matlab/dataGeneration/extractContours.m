% Extract contours from the input image
% Input:
%    img: the input image
%    method:  Canny detector (== 1)
%                   Structure edge detector (== 2)
% Output:
%    contour: the cell array of contours


function contour = extractContours(img, method, draw)

if nargin < 3
    draw = false;
end

persistent model;

% choose the method of edge detection
if method == 1         % Canny
    img_bw = im2bw(img, 0.8);
    BW = im2double(edge(img_bw, 'canny'));    
elseif method == 2    % Structure edge
%     load('structured edge detector/models/forest/modelFinal.mat');
    if isempty(model)
        model=load('models/forest/modelBsds');
        model=model.model;
        model.opts.multiscale=0; model.opts.sharpen=2; model.opts.nThreads=4;
        model.opts.nms = 1;   % enable non-maximum suppression
    end
    E = edgesDetect(img, model);
    BW = im2double(im2bw(E, 0.1));
end

if draw
    figure, imshow(E);
    figure, imshow(BW);
end
% contour = extractContBW(BW);
contour = extractContBW2(BW, E);

if draw
    showContours(contour, length(contour), 1:length(contour));
%     showContours(contour2, length(contour2), 1:length(contour2));
end

% display contours
% numCont = numel(contour);
% imgSize = size(img);
% BW2 = zeros(imgSize(1:2));
% 
% for i = 1:numCont
%     for j = 1:size(contour{i}, 1)
%         BW2(contour{i}(j, 1), contour{i}(j, 2)) = 1;
%     end
% end
% figure, imshow(BW2);

% imgSize = size(img);
% hFig = figure;
% set(hFig, 'Position', [200 100 1000 700]);
% hold on;
% 
% for i = 1:numCont
%     plot(contour{i}(:, 2), contour{i}(:, 1), 'LineWidth', 1.5);
%     L = numel(contour{i});
%     center = 2 * sum(contour{i}) / L;
%     text(center(2), center(1), num2str(i), 'FontSize', 12, 'Color', 'b');
% end
% 
% hold off;
% axis equal;
% axis ij;
% axis([0 imgSize(2) 0 imgSize(1)]);
% xlabel('x', 'FontSize', 14);
% ylabel('y', 'FontSize', 14);

end