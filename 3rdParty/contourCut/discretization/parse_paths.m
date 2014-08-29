function ind = parse_paths(p, d, sim)
% Finds the best path, removes all paths too similar to it, and repeats
% until we get a list of good paths which are not too similar to each other

[junk orig_ind] = sort(d, 'descend');
p2 = p(orig_ind);
d2 = d(orig_ind);

for i = 1:numel(p2)
    p2{i} = sort(unique(p2{i}));
end

ind = [];
inds = orig_ind;

while ~isempty(inds)
    % Get the next top path
    currp = p2{1};
    ind = [ind inds(1)];
    p2 = p2(2:end);
    d2 = d2(2:end);
    inds = inds(2:end);
    
    % Compute the percentage of nodes shared with the remaining paths
    dists = [];
    for i = 1:numel(p2)
        dists = [dists numel(intersect_sorted(currp, p2{i}))/min(numel(currp), numel(p2{i}))];
    end
    bad = dists > sim;
    % Remove bad remaining paths
    p2 = p2(~bad);
    d2 = d2(~bad);
    inds = inds(~bad);
end
 
