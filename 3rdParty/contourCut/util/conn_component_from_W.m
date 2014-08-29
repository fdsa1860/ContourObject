function [comp, n_conn, nb_pix] = conn_component_from_W(W_adj);
% [comp, n_conn, nb_pix] = conn_component_from_W(W_adj);
%     W_adj symmetric

n = size(W_adj, 1);
comp = zeros(n, 1);
nb_pix = [];

idx_remain = 1:n;
comp_id = 1;

while (length(idx_remain)>1)
    dist = mex_dijkstra2(W_adj, 1);
    idx_finite = find(~isinf(dist));
    comp(idx_remain(idx_finite)) = comp_id;
    nb_pix = [nb_pix; length(idx_finite)];
    idx = find(isinf(dist));
    W_adj = W_adj(idx, idx);
    idx_remain = idx_remain(idx);
    comp_id = comp_id + 1;
end

if (length(idx_remain)==1)
    comp(idx_remain) = comp_id;
    nb_pix = [nb_pix; length(idx_remain)];
    comp_id = comp_id + 1;
end

n_conn = comp_id - 1;
