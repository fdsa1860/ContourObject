function [pb,theta,x,y,pball] = pbCGTG_subpixel(im,radius,norient)
% function [pb,theta,x,y] = pbCGTG_subpixel(im,radius,norient)
% 
% Compute probability of boundary using CG and TG. (for subpixel accuracy)
% Modified by Qihui Zhu
%
% David R. Martin <dmartin@eecs.berkeley.edu>
% April 2003

if nargin<2, radius=[0.01 0.02 0.02 0.02]; end
if nargin<3, norient=8; end
if numel(radius)==1, radius=radius*ones(1,4); end

% beta from logistic fits (trainCGTG.m)
if all(radius==[0.01 0.02 0.02 0.02]), % 64 textons
  beta = [-4.5015774e+00 6.6845040e-01 1.3588346e-01 1.9537985e-01 5.3922927e-01];
  fstd = [ 1.0000000e+00 3.9505238e-01 1.4210176e-01 1.9449891e-01 1.9178634e-01];
  beta = beta ./ fstd;
else
  error(sprintf('no parameters for radius=[%g %g]\n',radius(1),radius(2)));
end

% get gradients
[cg,tg,gtheta] = detCGTG(im,radius,norient);

% compute oriented pb
[h,w,unused] = size(im);
pball = zeros(h,w,norient);
pbfit = zeros(h,w,norient);
for i = 1:norient,
  l = cg(:,:,1,i); l = l(:);
  a = cg(:,:,2,i); a = a(:);
  b = cg(:,:,3,i); b = b(:);
  t = tg(:,:,i); t = t(:);
  x = [ones(size(b)) l a b t];
  pbi = 1 ./ (1 + (exp(-x*beta')));
  pball(:,:,i) = reshape(pbi,[h w]);
  pbfit(:,:,i) = reshape(x*beta',[h w]);
end

% nonmax suppression and max over orientations
[unused,maxo] = max(pball,[],3);
pb = zeros(h,w);
x = zeros(h,w);
y = zeros(h,w);
theta = zeros(h,w);
r = 2.5;

% Interpolate theta
for i = 1:norient
    mask = (maxo == i);
    ind = find(mask);
    ind_ori = [mod(i+norient-2, norient)+1, i, mod(i, norient)+1];
    ind_pix = repmat(ind, [1, 3]) + repmat(ind_ori-1, [length(ind), 1])*h*w;
    theta2 = interp_circ(i*ones(size(ind)), pbfit(ind_pix), norient);
    theta(ind) = theta2;
end
    
% Interpolate pixel location
for i = 1:norient
    mask = (maxo == i);
    a1 = fitparab(pball(:,:,i),r,r,gtheta(i));
    a2 = fitparab(pbfit(:,:,i),r,r,gtheta(i));
    pbi = nonmax(max(0,a1),theta);
    [pbi2,xi,yi] = nonmax_subpixel(a2,theta);
    
    pb = max(pb,pbi.*mask);
    x = x.*~mask+xi.*mask;
    y = y.*~mask+yi.*mask;
end

pb = max(0,min(1,pb));

% mask out 1-pixel border where nonmax suppression fails
pb(1,:) = 0;
pb(end,:) = 0;
pb(:,1) = 0;
pb(:,end) = 0;
