% small test

% circle
c = [ 3 4];
r = 1;
t = 0:0.5:2*pi;

sx1 = c(1) + r * cos(t) + 0.0*randn(size(t));
sy1 = c(2) + r * sin(t) + 0.000*randn(size(t));


A = [0.9988 -0.05;0.05 0.9988];

plot(sx1,sy1,'b');


% sin
sx2 = 0.1:0.05:2*pi+1;
sy2 = sin(sx2);

hold on;plot(sx2,sy2,'g');hold off;

k = 0.5;
b = 1;
sx3 = 0:0.05:2*pi;
sy3 = k * sx3 + b;

hold on;plot(sx3,sy3,'r');hold off;

L = 6;

ind1 = 1:1+L-1;
% ind1 = 1:length(t);
% ind1 = 1:126;
ind2 = 5:5+L-1;
ind3 = 32:32+L-1;
ind4 = 100:100+L-1;

x1 = sx1(ind1);
y1 = sy1(ind1);
x2 = sx1(ind2);
y2 = sy1(ind2);
x3 = sx2(ind3);
y3 = sy2(ind3);
x4 = sx2(ind4);
y4 = sy2(ind4);

figure(2);
plot(x1,y1,'b');
hold;
plot(x2,y2,'g');
plot(x3,y3,'m');
plot(x4,y4,'r');
hold;
axis equal

% x1 = x1 - mean(x1);
% y1 = y1 - mean(y1);
% x2 = x2 - mean(x2);
% y2 = y2 - mean(y2);
% x3 = x3 - mean(x3);
% y3 = y3 - mean(y3);
% x4 = x4 - mean(x4);
% y4 = y4 - mean(y4);

u1 = diff(x1);
v1 = diff(y1);
u2 = diff(x2);
v2 = diff(y2);
u3 = diff(x3);
v3 = diff(y3);
u4 = diff(x4);
v4 = diff(y4);

figure(3);
plot(u1,v1,'b');
hold;
plot(u2,v2,'g');
plot(u3,v3,'m');
plot(u4,v4,'r');
hold;
axis equal

L = 44;

Hx1 = hankel(x1(1:ceil(L/2)),x1(ceil(L/2):end));
Hy1 = hankel(y1(1:ceil(L/2)),y1(ceil(L/2):end));
H1 = [Hx1;Hy1];

Hx2 = hankel(x2(1:ceil(L/2)),x2(ceil(L/2):end));
Hy2 = hankel(y2(1:ceil(L/2)),y2(ceil(L/2):end));
H2 = [Hx2;Hy2];

Hx3 = hankel(x3(1:ceil(L/2)),x3(ceil(L/2):end));
Hy3 = hankel(y3(1:ceil(L/2)),y3(ceil(L/2):end));
H3 = [Hx3;Hy3];

Hx4 = hankel(x4(1:ceil(L/2)),x4(ceil(L/2):end));
Hy4 = hankel(y4(1:ceil(L/2)),y4(ceil(L/2):end));
H4 = [Hx4;Hy4];

Hu1 = hankel(u1(1:ceil(L/2)),u1(ceil(L/2):end));
Hv1 = hankel(v1(1:ceil(L/2)),v1(ceil(L/2):end));
Hd1 = [Hu1;Hv1];

Hu2 = hankel(u2(1:ceil(L/2)),u2(ceil(L/2):end));
Hv2 = hankel(v2(1:ceil(L/2)),v2(ceil(L/2):end));
Hd2 = [Hu2;Hv2];

Hu3 = hankel(u3(1:ceil(L/2)),u3(ceil(L/2):end));
Hv3 = hankel(v3(1:ceil(L/2)),v3(ceil(L/2):end));
Hd3 = [Hu3;Hv3];

Hu4 = hankel(u4(1:ceil(L/2)),u4(ceil(L/2):end));
Hv4 = hankel(v4(1:ceil(L/2)),v4(ceil(L/2):end));
Hd4 = [Hu4;Hv4];

% H1 = H1';
% H2 = H2';
% H3 = H3';
% H4 = H4';
% Hd1 = Hd1';
% Hd2 = Hd2';
% Hd3 = Hd3';
% Hd4 = Hd4';

tic;

[U1,S1,V1] = svd(H1);
[U2,S2,V2] = svd(H2);
[U3,S3,V3] = svd(H3);
[U4,S4,V4] = svd(H4);
[Ud1,Sd1,Vd1] = svd(Hd1);
[Ud2,Sd2,Vd2] = svd(Hd2);
[Ud3,Sd3,Vd3] = svd(Hd3);
[Ud4,Sd4,Vd4] = svd(Hd4);
% H1 = U1*(S1>1e-3)*V1';
% H2 = U2*(S2>1e-3)*V2';
% H3 = U3*(S3>1e-3)*V3';
% H4 = U4*(S4>1e-3)*V4';

H1_p = H1 / (norm(H1*H1','fro')^0.5);
H2_p = H2 / (norm(H2*H2','fro')^0.5);
H3_p = H3 / (norm(H3*H3','fro')^0.5);
H4_p = H4 / (norm(H4*H4','fro')^0.5);

d12 = 2 - norm(H1_p*H1_p' + H2_p*H2_p', 'fro');
d13 = 2 - norm(H1_p*H1_p' + H3_p*H3_p', 'fro');
d23 = 2 - norm(H2_p*H2_p' + H3_p*H3_p', 'fro');
d14 = 2 - norm(H1_p*H1_p' + H4_p*H4_p', 'fro');
d24 = 2 - norm(H2_p*H2_p' + H4_p*H4_p', 'fro');
d34 = 2 - norm(H3_p*H3_p' + H4_p*H4_p', 'fro');

toc

d12
d13
d23
d14
d24
d34

tic;

% [U1,S1,V1] = svd(H1);
% [U2,S2,V2] = svd(H2);
% [U3,S3,V3] = svd(H3);
% [U4,S4,V4] = svd(H4);
% H1 = U1*(S1>1e-3)*V1';
% H2 = U2*(S2>1e-3)*V2';
% H3 = U3*(S3>1e-3)*V3';
% H4 = U4*(S4>1e-3)*V4';

Hx1 = bsxfun(@minus, Hx1, mean(Hx1));
Hy1 = bsxfun(@minus, Hy1, mean(Hy1));
Hx2 = bsxfun(@minus, Hx2, mean(Hx2));
Hy2 = bsxfun(@minus, Hy2, mean(Hy2));
Hx3 = bsxfun(@minus, Hx3, mean(Hx3));
Hy3 = bsxfun(@minus, Hy3, mean(Hy3));
Hx4 = bsxfun(@minus, Hx4, mean(Hx4));
Hy4 = bsxfun(@minus, Hy4, mean(Hy4));

H1 = [Hx1;Hy1];
H2 = [Hx2;Hy2];
H3 = [Hx3;Hy3];
H4 = [Hx4;Hy4];

H1_p = H1 / (norm(H1*H1','fro')^0.5);
H2_p = H2 / (norm(H2*H2','fro')^0.5);
H3_p = H3 / (norm(H3*H3','fro')^0.5);
H4_p = H4 / (norm(H4*H4','fro')^0.5);

d12 = 2 - norm(H1_p*H1_p' + H2_p*H2_p', 'fro');
d13 = 2 - norm(H1_p*H1_p' + H3_p*H3_p', 'fro');
d23 = 2 - norm(H2_p*H2_p' + H3_p*H3_p', 'fro');
d14 = 2 - norm(H1_p*H1_p' + H4_p*H4_p', 'fro');
d24 = 2 - norm(H2_p*H2_p' + H4_p*H4_p', 'fro');
d34 = 2 - norm(H3_p*H3_p' + H4_p*H4_p', 'fro');

toc

d12
d13
d23
d14
d24
d34

tic;

Hx1 = bsxfun(@minus, Hx1, mean(Hx1));
Hy1 = bsxfun(@minus, Hy1, mean(Hy1));
Hx2 = bsxfun(@minus, Hx2, mean(Hx2));
Hy2 = bsxfun(@minus, Hy2, mean(Hy2));
Hx3 = bsxfun(@minus, Hx3, mean(Hx3));
Hy3 = bsxfun(@minus, Hy3, mean(Hy3));
Hx4 = bsxfun(@minus, Hx4, mean(Hx4));
Hy4 = bsxfun(@minus, Hy4, mean(Hy4));

H1 = [Hx1;Hy1];
H2 = [Hx2;Hy2];
H3 = [Hx3;Hy3];
H4 = [Hx4;Hy4];

H1_p2 = H1 / norm(H1,'fro');
H2_p2 = H2 / norm(H2,'fro');
H3_p2 = H3 / norm(H3,'fro');
H4_p2 = H4 / norm(H4,'fro');

H1_p = bsxfun(@rdivide, H1, sqrt(sum(H1.^2))) / sqrt(size(H1,2));
H2_p = bsxfun(@rdivide, H2, sqrt(sum(H2.^2))) / sqrt(size(H2,2));
H3_p = bsxfun(@rdivide, H3, sqrt(sum(H3.^2))) / sqrt(size(H3,2));
H4_p = bsxfun(@rdivide, H4, sqrt(sum(H4.^2))) / sqrt(size(H4,2));


[U1,S1,V1] = svd(H1_p);
[U2,S2,V2] = svd(H2_p);
[U3,S3,V3] = svd(H3_p);
[U4,S4,V4] = svd(H4_p);
s1 = diag(S1);
s2 = diag(S2);
s3 = diag(S3);
s4 = diag(S4);

% d12 = 1 - sum(sum(abs((U1*sqrt(S1))'*(U2*sqrt(S2))).^2));
% d13 = 1 - sum(sum(abs((U1*S1)'*(U3*S3))));
% d23 = 1 - sum(sum(abs((U2*S2)'*(U3*S3))));
% d14 = 1 - sum(sum(abs((U1*S1)'*(U4*S4))));
% d24 = 1 - sum(sum(abs((U2*S2)'*(U4*S4))));
% d34 = 1 - sum(sum(abs((U3*S3)'*(U4*S4))));

d12 = 1 - sum(sum(((U1*sqrt(S1))'*(U2*sqrt(S2))).^2));
d13 = 1 - sum(sum(((U1*sqrt(S1))'*(U3*sqrt(S3))).^2));
d23 = 1 - sum(sum(((U2*sqrt(S2))'*(U3*sqrt(S3))).^2));
d14 = 1 - sum(sum(((U1*sqrt(S1))'*(U4*sqrt(S4))).^2));
d24 = 1 - sum(sum(((U2*sqrt(S2))'*(U4*sqrt(S4))).^2));
d34 = 1 - sum(sum(((U3*sqrt(S3))'*(U4*sqrt(S4))).^2));

toc

d12
d13
d23
d14
d24
d34

tic

Hd1_p = Hd1 / norm(Hd1,'fro');
Hd2_p = Hd2 / norm(Hd2,'fro');
Hd3_p = Hd3 / norm(Hd3,'fro');
Hd4_p = Hd4 / norm(Hd4,'fro');

[Ud1,Sd1,Vd1] = svd(Hd1_p);
[Ud2,Sd2,Vd2] = svd(Hd2_p);
[Ud3,Sd3,Vd3] = svd(Hd3_p);
[Ud4,Sd4,Vd4] = svd(Hd4_p);

d12 = 1 - sum(sum(abs((Ud1*Sd1)'*(Ud2*Sd2))));
d13 = 1 - sum(sum(abs((Ud1*Sd1)'*(Ud3*Sd3))));
d23 = 1 - sum(sum(abs((Ud2*Sd2)'*(Ud3*Sd3))));
d14 = 1 - sum(sum(abs((Ud1*Sd1)'*(Ud4*Sd4))));
d24 = 1 - sum(sum(abs((Ud2*Sd2)'*(Ud4*Sd4))));
d34 = 1 - sum(sum(abs((Ud3*Sd3)'*(Ud4*Sd4))));

toc

d12
d13
d23
d14
d24
d34

tic

d12 = subspace(Hd1,Hd2);
d13 = subspace(Hd1,Hd3);
d23 = subspace(Hd2,Hd3);
d14 = subspace(Hd1,Hd4);
d24 = subspace(Hd2,Hd4);
d34 = subspace(Hd3,Hd4);

toc

d12
d13
d23
d14
d24
d34

% figure(4);
% tt = 1:L;
% plot(tt,x1,'b',tt,y1,'b',tt,x2,'g',tt,y2,'g',tt,x3,'m',tt,y3,'m',tt,x4,'r',tt,y4,'r');
% legend x1 y1 x2 y2 x3 y3 x4 y4

% %% cvx test
% addpath('/home/xikang/research/code/toolbox/cvx');
% [m,n] = size(H1);
% W1 = eye(m);
% W2 = eye(n);
% H = zeros(size(H1));
% H_pre = ones(size(H));
% while norm(H-H_pre,'fro') > 1e-3
%     H_pre = H;
%     cvx_begin
%     b1 = [ones(8);zeros(8)];
%     b2 = [zeros(8);ones(8)];
%     variables Y(m,m) Z(n,n);
%     variables H(m,n) a1 a2;
%     a1*b1 + a2*b2 + H == H2;
%     [Y H; H' Z] == semidefinite(24);
%     % minimize(norm_nuc(H));
%     minimize(trace(W1*Y)+trace(W2*Z));
%     cvx_end
%     
%     sy = svd(Y);
%     sz = svd(Z);
%     W1 = inv(Y + sy(1)*eye(16));
%     W2 = inv(Z + sz(1)*eye(8));
%     
% end
% rmpath('/home/xikang/research/code/toolbox/cvx');

%% remove all dc components
% dc1 = [ones(8,1);zeros(8,1)];
% dc2 = [zeros(8,1);ones(8,1)];
% for i = 1:size(H1,2)
%     temp = H1(:,i);
%     temp = temp - (temp'*dc1)/(dc1'*dc1)*dc1 - (temp'*dc2)/(dc2'*dc2)*dc2;
%     temp = temp/norm(temp);
%     H1(:,i) = temp;
% end
% H1 = H1/sqrt(size(H1,2));
% for i = 1:size(H2,2)
%     temp = H2(:,i);
%     temp = temp - (temp'*dc1)/(dc1'*dc1)*dc1 - (temp'*dc2)/(dc2'*dc2)*dc2;
%     temp = temp/norm(temp);
%     H2(:,i) = temp;
% end
% H2 = H2/sqrt(size(H2,2));
% for i = 1:size(H3,2)
%     temp = H3(:,i);
%     temp = temp - (temp'*dc1)/(dc1'*dc1)*dc1 - (temp'*dc2)/(dc2'*dc2)*dc2;
%     temp = temp/norm(temp);
%     H3(:,i) = temp;
% end
% H3 = H3/sqrt(size(H3,2));

%% compute translation
% svd(Hx1)
% svd(Hx2)
% svd([Hx1 Hx2])
x = x1+10;
% H = hankel_mo(x,[3,24]);
H = hankel_mo(x);
s = sym('s');
d = det((H+s)*(H+s).');
coef = sym2poly(vpa(d));
r = roots(coef);
r

T = findTranslation(x1')

% addpath(genpath('/home/xikang/research/code/toolbox/multipoly'));
% pvar s;
% d = det((H+s)*(H+s)')
% coef = full(d.coef)
% r = roots(coef);
% disp('original r is');
% r
% % filter out small imaginary part
% thr = 0.1;
% ind = abs(imag(r))<thr*abs(real(r));
% r(ind) = real(r(ind));
% disp('imag filtered r is');
% r
% % find double roots
% thr_d = 0.01;
% r = sort(r);
% counter = 1;
% valid = false(length(r));
% while counter < length(r)
%     if abs(r(counter)-r(counter+1))/abs(r(counter)) < thr_d
%         valid(counter) = true;
%         counter = counter + 2;
%     else
%         counter = counter + 1;
%     end
% end
% r = r(valid);
% disp('double filtered r is');
% r

% rmpath(genpath('/home/xikang/research/code/toolbox/multipoly'));
% addpath('/home/xikang/research/code/toolbox/cvx');
% cvx_begin
% variable c;
% W = (H+c)*(H+c)';
% log_det(W) == 0;
% minimize(0);
% cvx_end
% rmpath('/home/xikang/research/code/toolbox/cvx');

