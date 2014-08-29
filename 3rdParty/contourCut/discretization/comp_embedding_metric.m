function [e_area, min_id, max_id] = comp_embedding_metric(eig_vec, x, y, s2p)
% [e_area, min_id, max_id, radius] = comp_embedding_metric(eig_vec, s2p, metric);
%
% Computes the metric score for each segment in the given eigenvector, used
% for tracing out contours.

p2s = s2p';
nb_segs = size(p2s, 2);
e_area = zeros(nb_segs, 1);
min_id = zeros(nb_segs, 1);
max_id = zeros(nb_segs, 1);

for ii = 1:nb_segs
    idx = find(p2s(:, ii));
    if (length(idx) == 1)
        min_id(ii) = idx;
        max_id(ii) = idx;
        continue;
    end
    vec = eig_vec(idx);

    p_angle = angle(vec);
    [min_ang, id1] = min(p_angle);
    [max_ang, id2] = max(p_angle);
    min_id(ii) = idx(id1);
    max_id(ii) = idx(id2);

    x2 = x(idx);
    y2 = y(idx);
%     [coeff score] = princomp([x2 y2]);
%     d = score(:,1);
%     [min_ang, id1] = min(d);
%     [max_ang, id2] = max(d);
    
    
    W = ipdm([x2 y2]);
    D = kruskal_mst(sparse(W));
    D_dist = floyd_warshall_all_sp(D);
    [junk ind] = max(D_dist(:));
    [id1 id2] = ind2sub(size(W), ind);
    
        
    min_id(ii) = idx(id1);
    max_id(ii) = idx(id2);


    e_area(ii) = 0;

end
