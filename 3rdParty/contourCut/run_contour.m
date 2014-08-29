function [cont_info] = run_contour(img, nb_eig, nb_clusters, dst_file, para)
% Compute contours from complex embedding
%
% INPUT
%   img           Image file name, image matrix or edgels ({x,y,gx,gy}).
%   nb_eig        Number of eigenvectors to compute (default:200). More
%                 eigenvectors means more contours.
%   nb_clusters   Number of clusters; controls graph coarseness (default:500)
%                 Fewer clusters is faster.  Set to 0 for no clustering.
%   dst_file      Output file name. Not saved if empty or unspecified.
%   para          Other parameters (defulat: see current_para.m)
%
% OUTPUT
%   cont      A cell array containing contours. Each cell contains a 3xm
%             vector [x;y;theta] (tangent direction) of contour points.
%   cont_info Other contour information including complex eigenvectors for
%             debugging

total = tic;

if ~exist('nb_eig', 'var')
    nb_eig = 200;
end
if ~exist('nb_clusters', 'var')
    nb_clusters = 500;
end
if ~exist('para', 'var')
    para = current_para;
end

imgh = size(img, 1);
imgw = size(img, 2);

% Compute Pb
fprintf('Computing Pb\n');
tic;
[pb, pb_theta] = pbCGTG(img);
toc;

%Remove border Pb pixels
pb(end-para.border+1:end,:) = 0;
pb(1:para.border,:) = 0;
pb(:,end-para.border+1:end) = 0;
pb(:,1:para.border) = 0;

%Threshold Pb to get edges
ind = find(pb > para.pb_thres);
[y_orig x_orig] = find(pb > para.pb_thres);
x_orig = [x_orig x_orig];
y_orig = [y_orig y_orig];
gx_orig = sin(pb_theta(ind));
gy_orig = -cos(pb_theta(ind));


% Compute W for the full image
W_orig = compute_W(x_orig, y_orig, gx_orig, gy_orig, imgh, imgw, img, para);

if strcmp(para.algorithm, 'greedy')
    fprintf('Finding local maxima\n');
    tic;
    [pixel_order scores] = greedy_alg(W_orig,x_orig,y_orig,para);
    
    % Post-processing and output
    cont_info = struct('x', x_orig(:,1), 'y', y_orig(:,1), 'gx', gx_orig, 'gy', gy_orig);
    cont_info.pixel_order = pixel_order;
    
    cont_info = struct( 'img', img, 'x', x_orig(:,1), 'y', y_orig(:,1), 'gx', gx_orig, 'gy', gy_orig, 'imgh', imgh, 'imgw', imgw);
    cont_info.para = para;
    cont_info.pixel_order = pixel_order;
    toc
    
else
    
    % Cluster into fragments using normalized cut
    if nb_clusters == 0
        % Don't cluster
        gx = gx_orig;
        gy = gy_orig;
        s2p = speye(size(W_orig));
    else
        fprintf('Compressing graph\n');
        tic;
        [x y gx gy s2p] = compressW(W_orig, x_orig, y_orig, gx_orig, gy_orig, imgh, imgw, pb_theta, nb_clusters);
        toc;
    end
    
    % Compute aggregate W matrix
    W = s2p*W_orig*s2p';
    W = W.*(1-speye(size(W)));
    
    
    % Compute eigenvectors
    fprintf('Solving eigenvalue problem\n');
    tic;
    [eig_vec lambda F Pi P] = ccutW(W, para.delta_min, para.delta_max, para.delta_step, nb_eig, para.algorithm);
    toc;
    
    
    % We do discretization on the full image space, so we need to translate the
    % fragment-eigenvectors back into the full image space by mapping every
    % pixel in a fragment to the same point in the embeddings
    eig_vec_full = s2p'*eig_vec;
    
    % Cycle tracing
    fprintf('Tracing cycles\n');
    tic;
    res_info = trace_cycle(lambda, eig_vec_full, [x_orig(:,1);x_orig(:,1)], [y_orig(:,1);y_orig(:,1)], [imgh imgw], F, Pi, s2p, para);
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
    
    if para.find_closest_maxima
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
        
    end
    
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
    
end
% Save to file if necessary
if (exist('dst_file', 'var') && ~isempty(dst_file))
    save(dst_file);
end

toc(total);