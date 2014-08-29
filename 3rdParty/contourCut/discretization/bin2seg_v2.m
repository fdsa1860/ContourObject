function segs = bin2seg_v2(p2b, x, y, img_sz, para);
% segs = bin2seg_v2(p2b, x, y, img_sz, para);

% Parsing parameters
if (nargin < 5)
    para.radius = 2;
    para.nb_bin = 16;
end

nb_pix = size(p2b, 1)/2;
nb_eigs = size(p2b, 2)/para.nb_bin;
img_h = img_sz(1);
img_w = img_sz(2);
se = ones(3);

ind = cell(2,1);

si = zeros(nnz(p2b), 1);
sj = si;
val = si;
pid = 1;

% Slow implementation
for ii = 1:nb_eigs
    nb_seg = 0;
    for jj = 1:para.nb_bin
        % Split edgelets into halves
        ind{1} = find(p2b(1:nb_pix, (ii-1)*para.nb_bin+jj)); 
        ind{2} = find(p2b(nb_pix+1:end, (ii-1)*para.nb_bin+jj))+nb_pix;
        for kk = 1:2
            % Faster implementation
            img = sparse(y(ind{kk}), x(ind{kk}), 1, img_h, img_w);
%             img2 = mex_sparse_imdilate(img, se);
            img2 = img;
            [label, n] = mex_sparse_bwlabel(img2, 8);
            
            img_seg = label.*img;
            pix_id = y(ind{kk})+(x(ind{kk})-1)*img_h;
            
            nb_new = length(ind{kk});
            si(pid:pid+nb_new-1) = ind{kk};
            sj(pid:pid+nb_new-1) = ones(length(ind{kk}), 1)*ii;
            val(pid:pid+nb_new-1) = img_seg(pix_id)+nb_seg;
            pid = pid + nb_new;
            nb_seg = nb_seg + n;
        end
    end
end

si = si(1:pid-1);
sj = sj(1:pid-1);
val = val(1:pid-1);

segs = sparse(si, sj, val, nb_pix*2, nb_eigs);
