function endpts = find_endpts3(loop_id, s2p, l2p, x, y, img_sz, W_adj);
% endpts = find_endpts3(loop_id, s2p, l2p, x, y, img_sz, W_adj);
% New verison. If all fail, just compute farthest point

if (nargin < 7)
    W_adj = comp_W_adj(x,y,3,img_sz);
end

nb_pix = size(W_adj, 1);
nb_segs = length(loop_id);

pid = find(sum(s2p(loop_id, :)));
% if (length(pid) <= 1.33*sum(sum(l2p)>0))
%     % Loop detected
%     endpts = [-1, -1];
%     return;
% end
W_conn = l2p * l2p';
conn1 = [diag(W_conn, 1); W_conn(nb_segs, 1)];
conn2 = [W_conn(1, nb_segs); diag(W_conn, -1)];
conn = sparse(conn1 + conn2);

[bw, n] = mex_sparse_bwlabel(double(conn > 0), 4);

% Find more line segments...
if (n == 0)
    conn = [diag(W_conn, 2); diag(W_conn, 2-nb_segs)];
    conn = sparse(conn([nb_segs,1:(nb_segs-1)]));
    [bw2, n2] = mex_sparse_bwlabel(double(conn > 0), 4);
    if (n2 == 1 || n2 == 2)
        % Found
        n = n2;
        bw = bw2;
    end
end

% Potential endpoint components
endpts = [-1, -1];
switch n
    case 2
        idx = [];
        npts = zeros(3, 1);
        for jj = 0:2
            cid = find(bw==jj);
            [dummy, pix] = find(s2p(loop_id(cid), :));
            pix = unique(pix(:));
            idx = [idx; pix];
            npts(jj+1) = length(pix);
        end
        W_sub = double(W_adj(idx, idx)>0);
        max_id2 = find_farthest_pt(W_sub, 1:npts(1), (npts(1)+1):(npts(1)+npts(2)));
        max_id1 = find_farthest_pt(W_sub, (npts(1)+1):(npts(1)+npts(2)), 1:npts(1));
        if (max_id1 == -1 || max_id2 == -1)
            % Something wrong
            endpts = [0, 0];
            return;
        end
        max_id1 = find_farthest_pt(W_sub, max_id1);
        if (max_id1 == -1)
            % Something wrong
            endpts = [0, 0];
            return;
        end
        max_id2 = find_farthest_pt(W_sub, max_id2);
        endpts = [idx(max_id1), idx(max_id2)];
    case 1
        idx1 = find(bw==1);
        [dummy, pix1] = find(s2p(loop_id(idx1), :));
        endpts(1) = pix1(round(end/2));
        % Trace the other end and refine
        idx = find(sum([l2p, l2p]));
        start_id = find(idx==endpts(1));
        W_sub = double(W_adj(idx, idx)>0);
        max_id = find_farthest_pt(W_sub, start_id);
        if (max_id == -1)
            % Something wrong
            endpts = [0, 0];
            return;
        end        
        endpts(2) = idx(max_id);
        max_id1 = find_farthest_pt(W_sub, max_id);
        endpts(1) = idx(max_id1);
    otherwise
        % Undetermined
        endpts = [0, 0];
end

