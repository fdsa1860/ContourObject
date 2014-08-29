% generate midsize test data
% Xikang Zhang, 06/16/2014


data = cell(100,1);
counter = 1;

% lines
% the number of lines: 10
x0 = 50;
y0 = 50;
x = x0-10:0.1:x0+10;
theta_step = 0.5;
theta = -pi/2+theta_step:theta_step:pi/2-theta_step;
slope = tan(theta);
for i = 1:length(slope)
    y = slope(i) * (x - x0) + y0;
    data{counter} = [x; y]';
    counter = counter + 1;
end

x0 = 50;
y0 = 200;
x = x0-10:0.1:x0+10;
theta_step = 0.5;
theta = -pi/2+theta_step:theta_step:pi/2-theta_step;
slope = tan(theta);
for i = 1:length(slope)
    y = slope(i) * (x - x0) + y0;
    data{counter} = [x; y]';
    counter = counter + 1;
end

x0 = 50;
y0 = 350;
x = x0-10:0.1:x0+10;
theta_step = 0.5;
theta = -pi/2+theta_step:theta_step:pi/2-theta_step;
slope = tan(theta);
for i = 1:length(slope)
    y = slope(i) * (x - x0) + y0;
    data{counter} = [x; y]';
    counter = counter + 1;
end

x0 = 50;
y0 = 500;
x = x0-10:0.1:x0+10;
theta_step = 0.5;
theta = -pi/2+theta_step:theta_step:pi/2-theta_step;
slope = tan(theta);
for i = 1:length(slope)
    y = slope(i) * (x - x0) + y0;
    data{counter} = [x; y]';
    counter = counter + 1;
end

% circle
c = [150, 50; 150, 200; 150, 350; 150, 500];
r = [1; 7; 17; 29];
noise = [0, 0; 0, 0; 0, 0; 0, 0];
step = [0.2 0.1 0.05 0.025];

for i = 1:size(c,1)
    for j = 1:size(r,1)
        t = 0:step(i):2*pi;
        x = c(i,1) + r(j) * cos(t) + noise(i,1)*randn(size(t));
        y = c(i,2) + r(j) * sin(t) + noise(i,2)*randn(size(t));
        data{counter} = [x; y]';
        counter = counter + 1;
    end
end

% eclipse
c = [250, 50; 250, 200; 250, 350; 250, 500];
a = [1; 7; 17; 29];
b = [2; 7/2; 17*3; 29/3];
noise = [0, 0; 0, 0; 0, 0; 0, 0];
t = 0:0.05:2*pi;

for i = 1:size(c,1)
    x = c(i,1) + a(i) * cos(t) + noise(i,1)*randn(size(t));
    y = c(i,2) + b(i) * sin(t) + noise(i,2)*randn(size(t));
    data{counter} = [x; y]';
    counter = counter + 1;
end

% rotated eclipse
c = [350, 50; 350, 200; 350, 350; 350, 500];
a = [1; 7; 17; 29];
b = [2; 7/2; 17*3; 29/3];
beta = [pi/4; pi/4; pi/4; pi/4];
noise = [0, 0; 0, 0; 0, 0; 0, 0];
t = 0:0.05:2*pi;

for i = 1:size(c,1)
    Rot = [cos(beta(i)), -sin(beta(i)); sin(beta(i)), cos(beta(i))];
    x_tmp = a(i) * cos(t);
    y_tmp = b(i) * sin(t);
    tmp = Rot * [x_tmp; y_tmp];
    x = c(i,1) + tmp(1,:) + noise(i,1)*randn(size(t));
    y = c(i,2) + tmp(2,:) + noise(i,2)*randn(size(t));
    data{counter} = [x; y]';
    counter = counter + 1;
end

% sin waves
c = [450, 50; 450, 200; 450, 350; 450, 500];
r = [29; 29; 29; 29];
noise = [0, 0; 0, 0; 0, 0; 0, 0];
t_start = [0; 0; 0; 0];
t_end = [4*pi; 4*pi; 4*pi; 4*pi];
step = [0.05; 0.05; 0.05; 0.10];
phase = [0; pi/4; 0; 0];
freq = [1; 1; 2; 2];

for i = 1:size(c,1)
    t = t_start(i):step(i):t_end(i);
    x = c(i,1)-25 + t*10/pi + noise(i,1)*randn(size(t));
    y = c(i,2) + r(i) * sin(freq(i)*t+phase(i)) + noise(i,2)*randn(size(t));
    data{counter} = [x; y]';
    counter = counter + 1;
end

% cubic curves
c = [550, 50; 550, 200; 550, 350; 550, 500];
a = [1, -1, -14, 24; 1 1 -17 15; 1, -2, -15, 36; 1 -1.9 -15.6 36.9];
noise = [0, 0; 0, 0; 0, 0; 0, 0];
t = -4:0.1:3;
step = [0.05; 0.10; 0.05; 0.10];
freq = [1; 1; 2; 2];

for i = 1:size(c,1)
%     t = t_start(i):step(i):t_end(i);
    x = c(i,1) + t*3 + noise(i,1)*randn(size(t));
    y = c(i,2) + a(i,:)*[t.^3; t.^2; t.^1; t.^0] + noise(i,2)*randn(size(t));
    data{counter} = [x; y]';
    counter = counter + 1;
end


indEmpty = cellfun(@isempty, data);
data(indEmpty) = [];

