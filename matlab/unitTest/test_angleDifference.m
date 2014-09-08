function [f1 f2] = test_angleDifference
% test angleDifference feature
% show that it is invariant to translation and rotation

addpath('../feature');

% generate dat1
x = 0:0.05:2*pi;
y = cos(x);
dat1 = [x;y]';
subplot(221);
plot(dat1(:,1),dat1(:,2),'b*');
xlabel('x');ylabel('y');title('original data: dat1');
axis('equal');

% rotate dat1 to dat2
T = 10;
theta = pi/4;
R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
dat2 = (R*dat1')'+T;
subplot(222);
plot(dat2(:,1),dat2(:,2),'g*');
xlabel('x');ylabel('y');title('rotated data: dat2');
axis('equal');

% get angle difference feature
f1 = angleDifference(dat1);
f2 = angleDifference(dat2);
subplot(223);
hold on;
plot(f1,'b+');
plot(f2,'go');
title('angle difference feature');
legend('feature from dat1','feature from dat2')
hold off;

rmpath('../feature');

end