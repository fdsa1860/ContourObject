function [pb,theta,x,y] = pbBGTG_subpixel(im,pres,radius,norient)
% function [pb,theta,x,y] = pbBGTG_subpixel(im,pres,radius,norient)
% Compute probability of boundary using BG and TG.
% Modified by Qihui Zhu
%
% David R. Martin <dmartin@eecs.berkeley.edu>
% April 2003

if nargin<2, pres='gray'; end
if nargin<3, radius=[0.01 0.02]; end
if nargin<4, norient=8; end
if numel(radius)==1, radius=radius*ones(1,2); end

% beta from logistic fits (trainBGTG.m)
if all(radius==[0.01 0.02]), % 64 textons
  if strcmp(pres,'gray'), % trained on grayscale segmentations
    beta = [ -4.6522915e+00  7.1345115e-01  7.0333326e-01 ];
    fstd = [  1.0000000e+00  3.7408935e-01  1.9171689e-01 ];
  elseif strcmp(pres,'color'), % trained on color segmentations
    beta = [ -4.4880396e+00  7.0690368e-01  6.5740193e-01 ];
    fstd = [  1.0000000e+00  3.7401028e-01  1.9181055e-01 ];
  else
    error(sprintf('Unknown presentation: %s',pres));
  end
  beta = beta ./ fstd;
else
  error(sprintf('no parameters for radius=[%g %g]\n',radius(1),radius(2)));
end

% get gradients
[bg,tg,gtheta] = detBGTG(im,radius,norient);

% compute oriented pb
[h,w,unused] = size(im);
pball = zeros(h,w,norient);
for i = 1:norient,
  b = bg(:,:,i); b = b(:);
  t = tg(:,:,i); t = t(:);
  x = [ones(size(b)) b t];
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
