function [eig_vec2, lambda2, ind] = prune_eig(eig_vec, lambda, para);
% [eig_vec2, lambda2, ind] = prune_eig(eig_vec, lambda, para);
% Prune eigenvalues according to para.
% 
% INPUT
%   eig_vec   nxk matrix of k eigenvectors
%   lambda    kx1 vector of eigenvalues
%   para      a structure of para_parse 
% 
% OUTPUT
%   eig_vec2  New eigenvectors
%   lambda2   New eigenvalues
%   ind       Index: lambda(ind)=lambda2
% 
% Qihui Zhu <qihuizhu@seas.upenn.edu>
% GRASP Lab, University of Pennsylvania
% 02/06/2010


if (nargin < 3)
    para.real_thres = 1e-3;
    para.real_min = 0.8;
end

tol = 1e-8;

% Remove all real eigenVECTORS
ind = find(max(abs(imag(eig_vec)),[],1)>para.real_thres);
fprintf('%d pruned (real), ', length(lambda)-length(ind));
eig_vec2 = eig_vec(:,ind);
lambda2 = lambda(ind);


% Remove eigenvalues whose real part is too small
ind2 = find(real(lambda2)>para.real_min);
fprintf('%d pruned (real<%f), ', length(lambda2)-length(ind2), para.real_min);
eig_vec2 = eig_vec2(:,ind2);
lambda2 = lambda2(ind2);
ind = ind(ind2);

% Check conjugate eigs
ind2 = 1:size(eig_vec2,2);%find(imag(lambda2)<0);
fprintf('%d pruned (conjugate).\n', length(lambda2)-length(ind2));
eig_vec2 = eig_vec2(:,ind2);
lambda2 = lambda2(ind2);
ind = ind(ind2);

% Check phase angle
if (isfield(para, 'max_phase'))
    ind2 = find(abs(angle(lambda2)) <= para.max_phase);
    fprintf('%d pruned (phase>%f).\n', length(ind)-length(ind2), para.max_phase);
    lambda2 = lambda2(ind2);
    eig_vec2 = eig_vec2(:,ind2);
    ind = ind(ind2);
end

% Check norm
if (isfield(para, 'min_norm'))
    ind2 = find(abs(lambda2) >= para.min_norm);
    fprintf('%d pruned (norm<%f).\n', length(ind)-length(ind2), para.min_norm);
    lambda2 = lambda2(ind2);
    eig_vec2 = eig_vec2(:,ind2);
    ind = ind(ind2);
end

