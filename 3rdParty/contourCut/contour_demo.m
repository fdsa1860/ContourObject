% Demo for contour grouping

% Load the image
img = im2double(imread('145086.jpg'));

% Run contour grouping and save to file
para = current_para;
[cont_info] = run_contour(img, 100, 500, 'demo_output.mat', para);

% Display contours
select_contour_conf(cont_info);
figure;
subplot2(1,1,1,1);
imshow(img);
hold on;
c = lines(numel(cont_info.pixel_order));
for i = 1:numel(cont_info.pixel_order)
    plot(cont_info.x(cont_info.pixel_order{i}), cont_info.y(cont_info.pixel_order{i}), '.-', 'color', c(i,:));
end