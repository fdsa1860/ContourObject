function res_info = trace_cycle(lambda, eig_vec, x, y, imgsz, Fs, Pis, s2p2, para)
% res_info = trace_cycle(lambda, eig_vec, x, y, imgsz, para, sel_mask);
% Find contours by tracing ''shortest'' cycles in the complex embedding space
%
% INPUT
%   lambda      A kx1 vector of eigenvalues
%   eig_vec     A nxk matrix of k eigenvectors
%   x           The x coordinates of edge points
%   y           The y coordinates of edge points
%   Fs          The F matrix for the clustered graph
%   Pis         The Pi matrix for the clustered graph
%   imgsz       Image size
%   para        parameters
%
% OUTPUT
%   res_info    A struct containing contour information
%


% Prune eigenvalues
[eig_vec, lambda, res_info.ind] = prune_eig(eig_vec, lambda, para);

% Initialize result data structure
res_info.loop_id = {};
res_info.eig_id = [];
res_info.e_area = [];
res_info.s2p = cell(length(lambda), 1);
res_info.nb_cont = zeros(length(lambda), 1);
res_info.pixel_order = [];
res_info.endpts = [];

% Binning
[bins, p2b] = eig2bin(eig_vec, para);

% Precompute adjacency matrix
W_adj = comp_W_adj(x,y,para.max_gap,imgsz);
W_adj2 = W_adj(1:end/2, 1:end/2);

% Trace cycles in each complex eigen space
n = 0;
str_len = 0;
for ii = 1:size(eig_vec, 2)
    vec = eig_vec(:, ii);
    
    [junk segs] = max(s2p2',[],2);
    segs(bins(:,ii)==0)=0;
    [b m segs] = unique(segs);
    segs = segs - 1;
    segs = sparse(segs);

    
    [W_seg, s2p, s2b] = comp_W_seg(W_adj2, segs, bins(:,ii), vec);
    
    
    % Here, we create the P matrix by removing the segments which have zeros
    % Get segment-to-segment mapping
    s2s = s2p*s2p2';
    % Get segments used now
    [b1 m1 n1] = unique(segs);
    bad = b1==0;
    m1 = m1(~bad);
    ind = full(segs(m1));
    % Translate to original segment space
    [junk ind2] = max(s2s(ind,:),[],2);
    % Get the new matrix
    F = Fs(ind2, ind2);
    % Get the Pi matrix
    Pi = Pis(ind2, ind2);
    
    
    [e_area, min_id, max_id] = comp_embedding_metric(vec,  x, y, s2p);
    W_seg = comp_W_metric(W_seg, min_id, max_id, vec, para.metric);
    
    % Restrict endpoints
    [W_seg, W_conn] = comp_W_endpts(W_seg, W_adj2, s2p, min_id, max_id, x, y, vec);
    
    % Trace the cycles
    [is_cycle, seg_id, e_area] = find_cycle_area_multi(W_seg, vec, s2p, s2b, F, Pi, para);
    
    % Select pixels
    res_info.s2p{ii} = s2p;
    res_info.nb_cont(ii) = length(seg_id);
    if ~isempty(seg_id)
        res_info.eig_id = [res_info.eig_id; ii*ones(length(seg_id), 1)];
        res_info.e_area = [res_info.e_area; e_area];
        
        for jj = 1:length(seg_id)
            res_info.loop_id{n+jj} = seg_id{jj};    
            [r c] = find(s2p(seg_id{jj},:));
            res_info.pixel_order{n+jj} = c;
        end
    end
    backspace_string = repmat('\b', [1 str_len]);
    str = sprintf('%d/%d %f%%%%', ii, size(eig_vec, 2), ii/size(eig_vec, 2)*100);
    str_len = length(sprintf(str));
    fprintf(backspace_string);
    fprintf(str);

    n = n+length(seg_id);
end
fprintf('\n');
