function [dists, paths] = get_loop3(W_seg, nb_loops, start_id, s2b, vec)
% [dists, paths] = get_loop(W_seg, nb_loops, start_id, s2b)

% This function finds long paths that take nb_loops around the origin.
% Unfortunately, the longest path problem is NP-complete.  If nb_loops==1,
% then we can create a directed, acyclic grpah and solve the problem
% exactly.  If nb_loops>1, then we calculate all the pair-wise longest 
% distances between start nodes and link them together.  If
% a contour actually takes multiple loops, then it should be a reasonable
% assumption that each loop's longest path will use different nodes.

currdists = -inf(numel(start_id));
currpaths = cell(numel(start_id));
dists = [];
paths = {};

nb_bins = size(s2b, 2);
[junk, bin_id] = find(s2b);

% Find the pair-wise longest distance between start nodes
curr_bin_id = bin_id(start_id(1));
W_seg_dag = W_seg;
% Find links which go to the current bin and kill them (to make a dag)
% These should only be some links from the previous bin
prev_bin = bin_id==curr_bin_id-1;
if curr_bin_id == 1
    prev_bin = bin_id==nb_bins;
end
prev_prev_bin = bin_id==curr_bin_id-2;
if curr_bin_id == 2
    prev_prev_bin = bin_id==nb_bins;
elseif curr_bin_id == 1
    prev_prev_bin = bin_id == nb_bins-1;
end
next_bin = bin_id==curr_bin_id+1;
if curr_bin_id == nb_bins
    next_bin = bin_id==1;
end
curr_bin = bin_id == curr_bin_id;
W_seg_dag(prev_bin | prev_prev_bin, curr_bin) = 0;
W_seg_dag(prev_bin, next_bin) = 0;
% Add the first bin to the end again
W_seg_dag = [W_seg_dag W_seg(:,curr_bin);
    sparse(sum(curr_bin), size(W_seg_dag,2)+sum(curr_bin))];

% Longest path
[D P]=floyd_warshall_all_sp(-W_seg_dag);



for node1 = 1:numel(start_id)

    % Find all other start nodes that are not too far off the radius of
    % this one
    r1 = abs(vec(start_id(node1)));
    r2 = abs(vec(start_id));
    ratio = r1./r2;
    ratio(ratio<1) = r2(ratio<1)./r1;
    start_id2 = find(start_id(ratio < 2));
    
    for node2 = start_id2'     
         path=[]; 
         while node2~=0, 
             path(end+1)=node2; 
             node2=P(node1,node2); 
         end; 
         path=fliplr(path);
         
        % Adjust for the added copy of node 1
        path(path > size(W_seg,1)) = path(path > size(W_seg,1)) - size(W_seg,1);
        dist = D(node1, size(W_seg,1)+node2);
        
        % Update values
        currpaths{node1, node2} = path(1:end-1);
        currdists(node1, node2) = dist;
    end
end

% Create a dag with the nb_loops+1 layers
W_loop = [sparse(size(currdists,1), size(currdists,2)) currdists];
for i = 1:nb_loops-1
    W_loop = [W_loop  sparse(size(W_loop,1), size(currdists,2)); ...
        sparse(size(currdists,1), size(W_loop,2)) currdists];
end
W_loop = [W_loop; sparse(size(currdists,1), size(W_loop,2))];

% Use longest path for each start node
for i = 1:numel(start_id)
    [cost pred] = bellman_ford_sp(-W_loop, i);
    dist = -cost(nb_loops*numel(start_id) + i);
    if isinf(dist), continue, end
    % Correct indices for the copies
    path2 = path_from_pred(pred, nb_loops*numel(start_id) + i);
    while any(path2 > numel(start_id))
        path2(path2 > numel(start_id)) = path2(path2 > numel(start_id)) - numel(start_id);
    end
    if numel(unique(path2(1:end-1))) < numel(path2(1:end-1))
        % It takes the same loop several times...
        continue;
    end
    path = [];
    for j = 1:numel(path2)-1
        path = [path currpaths{path2(j), path2(j+1)}];
    end
    dists = [dists dist];
    paths = [paths path];
end
t = 0;
    