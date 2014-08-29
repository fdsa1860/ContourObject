function w = get_seg_weight(segs, x, y, sel_mask);
% w = get_seg_weight(segs, x, y, sel_mask);

[nb_pix, nb_eig] = size(segs);
nb_pix = nb_pix/2;
[imgh, imgw] = size(sel_mask);

w = cell(nb_eig, 1);
for ii = 1:nb_eig
    idx = find(segs(:, ii));
    seg_id = full(segs(idx, ii));
    idx2 = mod(idx-1, nb_pix)+1;
    is_sel = sel_mask(y(idx2)+(x(idx2)-1)*imgh);
    
    nb_seg = max(seg_id);
    s = sum(sparse(idx2, seg_id, 1, nb_pix, nb_seg));    
    overlap = sum(sparse(idx2, seg_id, is_sel, nb_pix, nb_seg));
    w{ii} = full(overlap(:)./(s(:)+eps));
%     w{ii} = (1-w{ii}).*w{ii}*4;
end
