function W_adj = comp_W_adj(x,y,radius,img_sz)
% W_adj = comp_W_adj(x,y,radius,img_sz);

% Slow
img_h = img_sz(1);
nb_pix = size(x, 1);
[si,sj] = mex_img2ij(img_sz, radius, 1, y(1:end/2)+(x(1:end/2)-1)*img_h);
si = double([si; si+nb_pix/2; si+nb_pix/2; si]);
sj = double([sj; sj+nb_pix/2; sj; sj+nb_pix/2]);
val = [ones(length(si)/2, 1); 2*ones(length(si)/2, 1)];
% % not connected
% si = double([si; si+nb_pix/2]);
% sj = double([sj; sj+nb_pix/2]);
W_adj = sparse(si, sj, val, nb_pix, nb_pix);
