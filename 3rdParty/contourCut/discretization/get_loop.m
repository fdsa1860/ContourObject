function [dists, paths] = get_loop(W_seg, nb_loops, start_id, s2b)
% This function finds long paths that take nb_loops around the origin.
% Unfortunately, the longest path problem is NP-complete.  If nb_loops==1,
% then we can create a directed, acyclic grpah and solve the problem
% exactly.  If nb_loops>1, then we take a greedy approach by taking the
% longest path around, removing the nodes we've visited and continuing.  If
% a contour actually takes multiple loops, then it should be a reasonable
% assumption that each loop's longest path will use different nodes.
dists = [];
paths = {};

nb_bins = size(s2b, 2);
[junk bin_id] = max(s2b,[],2);

% Loop over possible starting nodes
for ii = 1:numel(start_id);
    jj = start_id(ii);
    curr_paths = {jj};
    curr_dists = 0;
    % Consider multiple loops
    % We do this as follows:  At the current cycle, we look at all possible
    % longest-cycle paths to the last bin and then extend it a cycle after
    % deleting the nodes it's already been through (we don't want it to loop
    % until it finishes all the cycles).
    
    curr_bin_id = bin_id(jj);
    
    % Loop the right number of times
    for loopnum = 1:nb_loops
        
        
        % Update each path
        new_curr_paths = {};
        new_curr_dists = [];
        for pathnum = numel(curr_paths):-1:1
            
            curr_bin_id = bin_id(curr_paths{pathnum}(end));
            
            % Find the longest paths to the last bin
            
            W_seg_dag = W_seg;
            % Find links which go to the current bin and kill them (to make a dag)
            prev_bin = bin_id==curr_bin_id-1;
            if curr_bin_id == 1
                prev_bin = bin_id==nb_bins;
            end
            prev_prev_bin = bin_id==curr_bin_id-2;
            if curr_bin_id == 1
                prev_prev_bin = bin_id==nb_bins-1;
            end
            if curr_bin_id == 2
                prev_prev_bin = bin_id==nb_bins;
            end
            next_bin = bin_id==curr_bin_id+1;
            if curr_bin_id == nb_bins
                next_bin = bin_id==1;
            end
            curr_bin = bin_id == curr_bin_id;
            W_seg_dag(:, next_bin) = 0;
            W_seg_dag(curr_bin,:) = W_seg(curr_bin,:);
            W_seg_dag(curr_bin,curr_bin) = W_seg(curr_bin,curr_bin);
            W_seg_dag(next_bin,next_bin) = W_seg(next_bin,next_bin);
            W_seg_dag(:, curr_bin) = 0;


            % Remove the nodes we've visited so far (except for the current start node)
            to_remove = curr_paths{pathnum}(1:end-1);
            W_seg_dag(to_remove, :) = 0;
            W_seg_dag(:,to_remove) = 0;

            % Compute longest path
            [cost pred] = dag_sp(-W_seg_dag, curr_paths{pathnum}(end));
            cost = -cost;
            % Record the paths and distance to each node in the last (or previous to last) bin
            inds = find((prev_bin | prev_prev_bin) & ~isinf(cost))';
            [junk idx] = sort(cost(inds), 'descend');
            inds = inds(idx);
            for i = inds(1:min(numel(inds),1))
                newpath = [curr_paths{pathnum}(1:end-1) path_from_pred(pred, i) ];
                new_curr_paths = [new_curr_paths newpath];
                new_curr_dists = [new_curr_dists curr_dists(pathnum)+cost(i)];
            end
        end
        curr_paths = new_curr_paths;
        curr_dists = new_curr_dists;
        % Prune the current paths: remove paths that are essentially
        % the same
        ind = parse_paths(curr_paths, curr_dists, 0.9);
        curr_paths = curr_paths(ind);
        curr_dists = curr_dists(ind);
    end
    % For each path we've found, we need to find the longest path back to
    % the start node

    for pathnum = numel(curr_paths):-1:1
        curr_bin_id = bin_id(curr_paths{pathnum}(end));
        
        % First, create the dag
        W_seg_dag = W_seg;
        % Find links which go to the current bin and kill them (to make a dag)
        next_bin = bin_id==curr_bin_id+1;
        if curr_bin_id == nb_bins
            next_bin = bin_id==1;
        end
        curr_bin = bin_id == curr_bin_id;
        W_seg_dag(:, next_bin) = 0;
        W_seg_dag(curr_bin,:) = W_seg(curr_bin,:);
        W_seg_dag(curr_bin,curr_bin) = W_seg(curr_bin,curr_bin);
        W_seg_dag(next_bin,next_bin) = W_seg(next_bin,next_bin);
        W_seg_dag(:, curr_bin) = 0;

    
        endnode = curr_paths{pathnum}(end);
        W_seg_dag = W_seg_dag;
        to_remove = curr_paths{pathnum}(2:end-1);
        W_seg_dag(to_remove, :) = 0;
        W_seg_dag(:,to_remove) = 0;

        [cost pred] = dag_sp(-W_seg_dag, endnode);
        cost = -cost;
        if isinf(cost(start_id(ii)))
            % Remove the path
            curr_paths = curr_paths([1:pathnum-1 pathnum+1:end]);
            curr_dists = curr_dists([1:pathnum-1 pathnum+1:end]);
        else
            % Update the path
            newpath = path_from_pred(pred, start_id(ii));
            newpath = newpath(1:end-1);
            
            curr_paths{pathnum} = [curr_paths{pathnum}(1:end-1) newpath];
            curr_dists(pathnum) = curr_dists(pathnum) + cost(start_id(ii));
        end
    end
    
    % Find the longest path
%     [maxcost ind] = max(curr_dists);
    paths = [paths curr_paths];
    dists = [dists curr_dists];
end