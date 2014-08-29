function [cont_info] = retrace(filename, para2)
% Starting with the .mat file saved from run_contour(), this function
% re-traces the embeddings using the given parameters.  This allows the
% embeddings to be re-traced without having to re-run Pb, graph clustering
% and eigenvalue solvers from scratch.

load(filename);
para = para2;

% Cycle tracing
fprintf('Tracing cycles\n');
tic;
i = 1:numel(lambda);
eig_vec_full = s2p'*eig_vec;
res_info = trace_cycle(lambda(i), eig_vec_full(:,i), [x_orig(:,1);x_orig(:,1)], [y_orig(:,1);y_orig(:,1)], [imgh imgw], F, Pi, s2p, para);
toc;

fprintf('Cleaning up contours\n');
tic;
pixel_order = res_info.pixel_order;
for i = 1:numel(pixel_order)
    p = pixel_order{i};
    p(p > size(x_orig,1)) = p(p > size(x_orig,1))-size(x_orig,1);
    W_seg = ipdm([x_orig(p,1) y_orig(p,1)]);
    D = prim_mst(sparse(W_seg));
    D_dist = johnson_all_sp(D);
    [junk ind] = max(D_dist(:));
    [ind1 ind2] = ind2sub(size(W_seg), ind);
    [d pred] = dijkstra_sp(D, ind1);
    pth = path_from_pred(pred, ind2);
    pixel_order{i} = p(pth);
end

    % Use contours as starting points for finding actual local maxima
    W = W_orig;
    P = normalize_by_row(W);
    opts.disp = 0;
    [s D] = eigs(P', 1, 'lr', opts);
    s = s*sign(s(1));
    % Computer F matrix
    Pi = spdiags(s,0,size(W,1),size(W,1));
    F = Pi*P;
    Pi_inv = spdiags(1./s,0,size(W,1),size(W,1));
    Wt = W';
    for i = 1:numel(pixel_order)
        contour = pixel_order{i};
        contour = trimcontour(contour, W, F, Pi, [x_orig;x_orig], [y_orig;y_orig],pb);
        contour = extendcontour(contour, W, F, Pi, [x_orig;x_orig], [y_orig;y_orig],pb,3);
        contour(contour > size(F,1)/2) = contour(contour > size(F,1)/2) - size(F,1)/2;
        pixel_order{i} = contour;
    end
    
    



toc;

ind = parse_paths(pixel_order, cellfun(@numel, pixel_order), para.max_overlap);
pixel_order = pixel_order(ind);
res_info.pixel_order = pixel_order;
res_info.eig_id = res_info.eig_id(ind);
res_info.e_area = res_info.e_area(ind);
res_info.loop_id = res_info.loop_id(ind);
toc;

% Post-processing and output
cont_info = struct('x', x_orig(:,1), 'y', y_orig(:,1), 'gx', gx, 'gy', gy);
cont_info.pixel_order = pixel_order;

cont_info = struct( 'img', img, 'x', x_orig(:,1), 'y', y_orig(:,1), 'gx', gx, 'gy', gy, 'imgh', imgh, 'imgw', imgw, ...
    'eig_vec', eig_vec, 'lambda', lambda, 'res_info', res_info);
cont_info.para = para;
cont_info.pixel_order = pixel_order;

toc(total);