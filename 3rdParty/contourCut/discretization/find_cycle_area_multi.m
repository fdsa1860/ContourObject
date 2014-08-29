function [is_cycle, seg_id, e_area] = find_cycle_area_multi(W_seg, eig_vec, s2p, s2b, F, Pi, para)
% [is_cycle, seg_id, e_area] = find_cycle_area_multi(W_seg, eig_vec, segs, bins, s2p, s2b, para);
% Only 1 eigenvector, multiple cycle detection added

seg_id = {};
is_cycle = sparse(1, size(W_seg, 1));
e_area = [];

nb_segs = size(W_seg, 1);

% Determine the starting nodes for tracing
[junk bin_id] = max(s2b,[],2);
[dummy, start_bin] = min(sum(s2b));
vec = s2p * eig_vec ./ sum(s2p,2);
start_id = find(bin_id == start_bin);
if (isempty(start_id))
    return;
end


dists = [];
paths = {};

% For each number of loops
for ii = 1:para.max_winding
    
        % Get the paths
        [curr_dists, curr_paths] = get_loop(W_seg, ii, start_id, s2b);
        
        % Record the data
        dists = [dists curr_dists];
        paths = [paths curr_paths];    
end
if isempty(dists)
    return
end

% Prune the paths so that they're not significantly overlapping
ind = parse_paths(paths, dists, para.max_overlap);
paths = paths(ind);
dists = dists(ind);

% Sort all cycles
[dists, idx] = sort(dists, 'descend');
paths = paths(idx);

nb_loops = 0;
% Take cycles with largest area
for jj = 1:min(para.max_loop_per_eig, numel(dists))
    is_cycle = is_cycle + sparse(1, paths{jj}, 1, 1, nb_segs);
    nb_loops = nb_loops + 1;
    seg_id = [seg_id paths{jj}];
    e_area = [e_area; dists(jj)];
end
