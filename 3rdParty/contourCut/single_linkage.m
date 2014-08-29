function [clusters, D] = single_linkage(W, n)
% W should be a (sparse) similarity matrix

D = W;

clusters = {};
for i = 1:size(W,1)
    clusters = [clusters; i];
end

while numel(clusters) > n
    % Find the closest clusters
    [r c] = find(D == max(max(D)),1);
    
    % Merge them
    clusters{r} = [clusters{r} clusters{c}];
    clusters = [clusters(1:c-1); clusters(c+1:end)];
    D(r,:) = max(D(r,:), D(c,:));
    D(:,r) = D(r,:);
    D = D([1:c-1 c+1:end],[1:c-1 c+1:end]);  
    disp(numel(clusters));
end