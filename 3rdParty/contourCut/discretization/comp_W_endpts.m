function [W_seg2, W_conn] = comp_W_endpts(W_seg, W_adj, s2p, min_id, max_id, x, y, eig_vec)
% [W_seg2, W_conn] = comp_W_endpts(W_seg, W_adj, s2p, min_id, max_id);

nb_segs = size(s2p, 1);
nb_pix = size(s2p, 2);

% Type 1: overlapping pixels
[r c] = find(s2p);
x2 = x(c);
y2 = y(c);
[b m n] = unique([x2 y2], 'rows');
s2p_fold = sparse(r, n, 1, size(s2p,1), max(n));
W_conn1 = (s2p_fold * s2p_fold') > 0;

% Type 2: endpoints are close
si = [1:nb_segs, 1:nb_segs]';
sj = mod([min_id; max_id]-1, nb_pix/2) + 1;
s2p_end = sparse(si, sj, 1, nb_segs, nb_pix/2);
W_conn2 = s2p_end * W_adj * s2p_end';

% Type 3: overlapping embedding locations (aggregated matrix)
[r c] = find(s2p);
x2 = real(eig_vec(c));
y2 = imag(eig_vec(c));
[b m n] = unique([x2 y2], 'rows');
s2p_fold = sparse(r, n, 1, size(s2p,1), max(n));
W_conn3 = (s2p_fold * s2p_fold') > 0;

% Restrict the connection between endpoints
W_conn = double((W_conn1+W_conn2+W_conn3) > 0);
W_seg2 = W_seg .* W_conn;
