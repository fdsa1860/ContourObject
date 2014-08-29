function [vec_l, lambda_l, allvals outds] = eig_asym(W, para)
% [vec_l, lambda_l] = eig_asym(W,para);
% Compute all eigenvectors of an asymmetric graph random walk matrix
% 
% INPUT
%   W         nxn sparse weight matrix.
%   para      Parameters for eigensolver (para_eig).
% 
% OUTPUT
%   vec_l     nxk matrix. k left eigenvectors of W.
%   lambda_l  kx1 vector. k left eigenvalues of W.
% 
% Qihui Zhu <qihuizhu@seas.upenn.edu>
% GRASP Lab, University of Pennsylvania
% 02/02/2010

if (nargin < 2)
    para.nb_eigs = 400;
    para.eigs_maxit = 500;
    para.eigs_tol = eigs_tol;
    para.eigs_order = 'lr';
end
nb_eigs = para.nb_eigs;
% nb_eigs = size(W,1);


% Eigensolver parameters
options.disp = 0;
options.maxit = para.eigs_maxit;
options.tol = para.eigs_tol;
options.isreal = 0;

% % Normalize W
P = normalize_by_row(W);
options.disp = 0;
alpha = 0.99;
[s D] = eigs(@(x)(alpha*P'*x + (1-alpha)/size(P,1) * repmat(sum(x), [numel(x) 1])), size(P,1), 1, 'lr', options);
s = s*sign(s(1));
F = spdiags(s, 0, numel(s), numel(s))*P;
Dg = spdiags(1./sqrt(s), 0, numel(s), numel(s));
Dg2 = spdiags(sqrt(s), 0, numel(s), numel(s));
P2 = Dg*F*Dg;



% Find eigenvalues
step = 0.01;
deltas = pi/500:step:pi/4;

%keep track of last 10 eigenvectors and eigenvalues
vals = nan([nb_eigs, 5]);
xs = nan([size(P2,1), nb_eigs, 5]);

%storage for final data
v2 = zeros(size(P2,1), nb_eigs);
d2 = zeros(1,nb_eigs);
outds = zeros(1, nb_eigs);

nomax = ones(nb_eigs,1);
allvals = zeros(nb_eigs, numel(deltas));
tic;
warning off;
% P2 = full(P2);
for ii = 1:numel(deltas)
    delta = deltas(ii);
    H1 = (cos(delta)*(P2+P2')*0.5 - 1i*sin(delta)*(P2-P2')*0.5);

    
    [V D] = eigs(H1, nb_eigs, 'lr', options);
% [V D] = eig(H1);
%     options.v0 = sum(V,2);
    D = real(diag(D));
    
    %sort by real part
    [junk ind] = sort(real(D), 'descend');
    D = D(ind)';
    V = V(:,ind);
   
    %save values
    vals(:,1:4) = vals(:,2:5);
    vals(:,5) = D;
    allvals(:,ii) = D;
    xs(:,:,1:4) = xs(:,:,2:5);
    xs(:,:,5) = V;
    %check for local maxima
    %smooth, for "flat" local maxima
    vals_conv = imfilter(vals,  normpdf(1:5, 3, 2), 'symmetric');
    for jj = find(nomax)'


        [pks locs] = findpeaks(vals_conv(jj,:));
        if ~isempty(pks)
            x = Dg*xs(:,jj,locs(1));
            x = x/norm(x);
            v2(:,jj) = Dg*x;
            d2(jj) = vals(jj,locs(1));
%             d2(jj) = abs(x' * P2 * x);
            outds(:,jj) = deltas(ii);
%             disp([jj delta]);
            nomax(jj) = 0;
        end
    end
    
    fprintf('%f%%\n', 100*ii/numel(deltas));
end
warning on;
toc;
%only keep ones which have a local max
valid = d2 ~= 0;
d2 = d2(valid);
v2 = v2(:,valid);
outds = outds(valid);

dim_list = 1:min(nb_eigs, numel(d2));
[void, idx2] = sort(abs(d2), 'descend');
vec_l = double(v2(:, idx2(dim_list)));
lambda_l = double(d2(idx2(dim_list)));
outds = outds(idx2(dim_list));
