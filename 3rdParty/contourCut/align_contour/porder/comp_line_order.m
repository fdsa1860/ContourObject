% Handle line order
function [pixel_order2, dist_test] = comp_line_order(pid, x, y, max_gap, start_id);

pid = pid(:);
px = x(pid);
py = y(pid);
px = px-min(px)+1;
py = py-min(py)+1;
imgh = max(py);
imgw = max(px);

% Determine the max gap. To do more precisely here: limited to 3 now
bmap = sparse(py, px, 1, imgh, imgw);
[label, m] = mex_sparse_bwlabel(bmap, 8);
if (m==1)
    max_gap = 1;
else
    [label, m] = mex_sparse_bwlabel(bmap, 24);
    if (m==1)
        max_gap = 2;
    end
end
[si,sj] = mex_img2ij([imgh, imgw], max_gap, 1, py+(px-1)*imgh);
val = sqrt((px(si)-px(sj)).^2+(py(si)-py(sj)).^2);
W_dist = sparse(double(si), double(sj), val, length(px), length(px));

% Double check the graph is connected
dist_test = mex_dijkstra2(W_dist,1);
if (any(isinf(dist_test)))
    pixel_order2 = [];
    return;
end

% Compute midpoint and find one endpoint
if (start_id == -1)
    [dummy, mid_id] = min((px-mean(px)).^2+(py-mean(py)).^2);
    end_id1 = find_farthest_pt(W_dist, mid_id);
else
    end_id1 = start_id;
end
[dist1, prev1] = mex_dijkstra2(W_dist, end_id1);
[dist, pixel_order] = sort(dist1, 'ascend');

% Get distance from the other endpoint
end_id2 = pixel_order(end);
[dist2, prev2] = mex_dijkstra2(W_dist,end_id2);

% To speed up
idx = end_id2;
id_list = idx;
while(idx ~= end_id1 && idx ~= -1)
    idx = prev1(idx);
    id_list = [id_list; idx];
end

% Create bitmap, prune branches
imap = sparse(py, px, 1:length(px), imgh, imgw);
invalid_idx = find(dist1+dist2>dist(end)+max_gap);
se = ones(3);
bmap2 = sparse(py(id_list), px(id_list), 1, imgh, imgw);;
bmap2 = mex_sparse_imdilate(bmap2, se);
bmap2 = bmap2 .* bmap;
bmap = double(bmap & ~bmap2);
[label, m] = mex_sparse_bwlabel(bmap, 8);
del_label = unique(label(py(invalid_idx)+(px(invalid_idx)-1)*imgh));
for ii = 1:length(del_label)
    ind = del_label(ii);
    bmap(find(label==ind)) = 0;
end
pixel_order1 = [imap(find(bmap)); imap(find(bmap2))];
[dummy, idx] = sort(dist1(pixel_order1), 'ascend');
pixel_order2 = pid(pixel_order1(idx));

[comp, n_conn] = conn_component_from_W(W_dist(pixel_order1(idx), pixel_order1(idx)));
if (n_conn > 1)
    % Remove isolated pixels
    valid_idx = find(comp == comp(1));
    pixel_order2 = pid(pixel_order1(idx(valid_idx)));
end

% % Fix: if isolated pixels appear, remove it
% [comp, n_conn, nb_pix] = conn_component_from_W(W_dist(pixel_order1(idx), pixel_order1(idx)));
% if (n_conn > 1)
%     [dummy, idx_n] = sort(nb_pix, 'descend');
%     to_remove = find(comp~=idx_n(1));
%     if (length(to_remove) < 0.1*length(comp))
%         idx(to_remove) = [];
%         pixel_order2 = pid(pixel_order1(idx));
%     else
%         error('Large disconnected piece');
%     end
% end
