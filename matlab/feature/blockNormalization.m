% block normalization

function norm_feat = blockNormalization(feat)

ndim = ndims(feat);
if ndim~=3
    error('the input feat should be dimension 3\n');
end

nr = size(feat, 1);
nc = size(feat, 2);

Hr = hankel(1:2,2:nr);
ind_r = Hr(:);
Hc = hankel(1:2,2:nc);
ind_c = Hc(:);
norm_feat = feat(ind_r, ind_c, :);

for i = 1:nr
    for j = 1:nc
        tmp = norm_feat(i:i+1, j:j+1, :);
        tmp = tmp / (norm(tmp(:)) + 1e-6);
        tmp(tmp>0.2) = 0.2;
        tmp = tmp / (norm(tmp(:)) + 1e-6);
        norm_feat(i:i+1, j:j+1, :) = tmp;
    end
end


end
