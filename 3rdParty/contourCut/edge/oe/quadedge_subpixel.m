% function [x,y,gx,gy,par,threshold,mag,mage,g,FIe,FIo,mago] = quadedge_subpixel(I,par,threshold);
% Revised by Qihui Zhu

% Based on:
% Timothee Cour
% GRASP Lab, University of Pennsylvania, Philadelphia
% Date: 28-Jul-2006 09:15:41
% DO NOT DISTRIBUTE

% based on Stella X. Yu, 2001
% Input:
%    I = image
%    par = vector for 4 parameters
%      [number of filter orientations, number of scales, filter size, elongation]
%      To use default values, put 0.
%    threshold = threshold on edge strength
% Output:
%    [x,y,gx,gy] = locations and gradients of an ordered list of edgels
%       x,y could be horizontal or vertical or 45 between pixel sites
%       but it is guaranteed that there [floor(y) + (floor(x)-1)*nr]
%       is ordered and unique.  In other words, each edgel has a unique pixel id.
%    par = actual par used
%    threshold = actual threshold used
%    mag = edge magnitude
%    mage = phase map
%    g = gradient map at each pixel
%    [FIe,FIo] = odd and even filter outputs
%    mago = odd filter output of optimum orientation

% Stella X. Yu, 2001

%TODO : revoir indexes finaux -> coord ij

% Revised: 
%   The first column of x,y will be integer coordinates, the second column will 
%   be decimal offset with respect to the first column.

function [x,y,gx,gy,par,threshold,mag,mage,g,FIe,FIo,mago] = quadedge_subpixel(I,par,threshold);

if nargin<3 | isempty(threshold),
    threshold = 0.2;
end

[p,q,r] = size(I);
def_par = [8,1,20,3];

% take care of parameters, any missing value is substituted by a default value
if nargin<2 | isempty(par),
    par = def_par;
end
par(end+1:4)=0;
par = par(:);
j = (par>0);
have_value = [ j, 1-j ];
j = 1; n_filter = have_value(j,:) * [par(j); def_par(j)];
j = 2; n_scale  = have_value(j,:) * [par(j); def_par(j)];
j = 3; winsz    = have_value(j,:) * [par(j); def_par(j)];
j = 4; enlong   = have_value(j,:) * [par(j); def_par(j)];

% always make filter size an odd number so that the results will not be skewed
j = winsz/2;
if not(j > fix(j) + 0.1),
    winsz = winsz + 1;
end

% filter the image with quadrature filters
FBo = make_filterbank_odd2(n_filter,n_scale,winsz,enlong);
FBe = make_filterbank_even2(n_filter,n_scale,winsz,enlong);
n = ceil(winsz/2);

f = [fliplr(I(:,2:n+1)), I, fliplr(I(:,q-n:q-1))];
f = [flipud(f(2:n+1,:)); f; flipud(f(p-n:p-1,:))];


% FIo = fft_filt_2_optimized(f,FBo);
% FIe = fft_filt_2_optimized(f,FBe);
FIo = correlation2d(f,FBo,'same');
FIe = correlation2d(f,FBe,'same');
FIo = FIo(n+[1:p],n+[1:q],:);
FIe = FIe(n+[1:p],n+[1:q],:);

% compute the orientation energy and recover a smooth edge map
% pick up the maximum energy across scale and orientation
% even filter's output: as it is the second derivative, zero cross localize the edge
% odd filter's output: orientation
mag = sqrt(sum(FIo.^2,3)+sum(FIe.^2,3));
mag_a = sqrt(FIo.^2+FIe.^2);

[tmp,max_id] = max(mag_a,[],3);
base_size = p * q;
id = [1:base_size]';
mage_ori = reshape(FIe(id+(max_id(:)-1)*base_size),[p,q]);
mage = (mage_ori>0) - (mage_ori<0);

ori_incr=pi/n_filter; % to convert jshi's coords to conventional image xy
ori_offset=ori_incr/2;
theta = ori_offset+([1:n_filter]-1)*ori_incr; % orientation detectors
% [gx,gy] are image gradient in image xy coords, winner take all
mago = reshape(FIo(id+(max_id(:)-1)*base_size),[p,q]);
ori = theta(max_id);
ori = ori .* (mago>0) + (ori + pi).*(mago<0);
gy = mag .* cos(ori);
gx = -mag .* sin(ori);
g = cat(3,gx,gy);

% % Use Gaussian to compute gradient
gau = fspecial('gaussian', 8, 1);
sI = imfilter(I, gau, 'replicate');
[gx,gy] = gradient(sI);
g = cat(3,gx,gy);

% phase map: edges are where the phase changes
mag_th = max(mag(:)) * threshold;
eg = (mag>mag_th);
h = eg & [(mage(:,2:q) ~= mage(:,1:q-1)), zeros(p,1)];
v = eg & [(mage(2:p,:) ~= mage(1:p-1,:)); zeros(1,q)];
[y1,x1] = find(h & ~v);     % horizontal only
[y2,x2] = find(~h & v);     % vertical only
[y3,x3] = find(h & v);      % both horizontal and vertical
x = [x1;x2;x3];
y = [y1;y2;y3];
k = y + (x-1) * p;
gx = g(k);
gy = g(k+p*q);

% Obtain subpixel precision by interpolation
k1 = k(1:length(x1));
k2 = k(length(x1)+1:length(x1)+length(x2));
k3 = k(length(x1)+length(x2)+1:end);
lx = zc_interp(mage_ori(k3),mage_ori(k3+p))+eps;
ly = zc_interp(mage_ori(k3),mage_ori(k3+1))+eps;
lxy = lx.*ly./(lx.^2+ly.^2);
sx = [  zc_interp(mage_ori(k1),mage_ori(k1+p)); ... % for x1
        zeros(size(k2)); ...                        % for x2
        ly.*lxy ...                                 % for x3
        ];
sy = [  zeros(size(k1)); ...                        % for y1
        zc_interp(mage_ori(k2),mage_ori(k2+1)); ... % for y2
        lx.*lxy ...                                 % for y3
        ];
x = [x,x+sx];
y = [y,y+sy];
    
        
function x3 = zc_interp(y1,y2);

x3 = abs(y1)./(abs(y2-y1)+eps);
x3(find(y1==y2)) = 0;
