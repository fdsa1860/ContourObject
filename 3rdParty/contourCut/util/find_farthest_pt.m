function [pid, dist] = find_farthest_pt(W, start_id, subset);

dist = mex_dijkstra2(sparse(W), start_id);
if (nargin == 3)
    dist = dist(:, subset);
end
[dummy, pid] = max(min(dist, [], 1));
if (nargin == 3)
    pid = subset(pid);
end
