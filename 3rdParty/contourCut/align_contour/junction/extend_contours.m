function test_cts2 = extend_contours(test_cts, jct_id, branch_info);

min_overlap = 8;
max_pass = 5;
max_overlap_ratio = 0.95;
max_overlap_ratio = 0.9;

n = length(test_cts.pixel_order);
np = length(test_cts.x(:,1));

si = [];
sj = [];
val = [];
len = zeros(n, 1);
for ii = 1:n
    k = length(test_cts.pixel_order{ii});
    si = [si; test_cts.pixel_order{ii}];
    sj = [sj; ones(k, 1)*ii];
    val = [val; (1:k)'];
    len(ii) = k;
end
p2c = sparse(si, sj, val, np, n);
is_jct = sparse(jct_id, 1, 1, np, 1);

if (~isfield(test_cts, 'is_loop'))
    test_cts = find_loop(test_cts);
end

test_cts2 = test_cts;
clist3 = [];
p2c3 = [];

% One end
for ii = 1:n
%     disp(ii);
    if (test_cts.is_loop(ii))
        continue;
    end
    
    pid = test_cts.pixel_order{ii};
    
    % Align contour ends
    idx_jct = find(is_jct(pid));
    if (length(idx_jct) > 0 && length(pid)-idx_jct(end)<=max_pass)
        idx = find(p2c(:, ii) > idx_jct(end));
        p2c_tmp = p2c(:, ii);
        p2c_tmp(idx) = 0;
        [clist3, p2c3] = append_clist(clist3, p2c3, pid(1:idx_jct(end)), p2c_tmp);        
        continue;
    end
    
    % Extension by BFS 
    [clist2, p2c2] = bfs_extend({pid}, test_cts, p2c(:, ii), p2c, is_jct, min_overlap, max_overlap_ratio);
    if (isempty(clist2))
        [clist3, p2c3] = append_clist(clist3, p2c3, pid, p2c(:, ii));
        continue;
    end
%     if (length(clist2) > 1)
%         fprintf('(1) Contour %d: multiple branch?\n', ii);
%     end
    [clist2, idx] = sort_clist_by_len(clist2);
    clist2 = clist2(1);
    p2c2 = p2c2(:, idx(1));
    [clist3, p2c3] = append_clist(clist3, p2c3, clist2, p2c2);
end
valid_idx = prune_repeat_contours(p2c3, max_overlap_ratio);
clist3 = clist3(valid_idx);
p2c3 = p2c3(:, valid_idx);

% The other end
clist_all = [];
p2c_all = [];
for ii = 1:length(clist3)
    pid = clist3{ii}(end:-1:1);
    p2c_e = p2c3(:, ii);
    idx = find(p2c_e);
    p2c_e(idx) = max(p2c_e(idx))+1-p2c_e(idx);
    
    % Align contour ends
    idx_jct = find(is_jct(pid));
    if (length(idx_jct) > 0 && length(pid)-idx_jct(end)<=max_pass)
        idx = find(p2c(:, ii) > idx_jct(end));
        p2c_tmp = p2c(:, ii);
        p2c_tmp(idx) = 0;
        [clist_all, p2c_all] = append_clist(clist_all, p2c_all, pid(1:idx_jct(end)), p2c_tmp);
        continue;
    end
    
    [clist2, p2c2] = bfs_extend({pid}, test_cts, p2c_e, p2c, is_jct, min_overlap, max_overlap_ratio);
    if (isempty(clist2))
        [clist_all, p2c_all] = append_clist(clist_all, p2c_all, pid, p2c(:, ii));
        continue;
    end
%     if (length(clist2) > 1)
%         fprintf('(2) Contour %d: multiple branch?\n', ii);
%     end
    [clist2, idx] = sort_clist_by_len(clist2);
    clist2 = clist2(1);
    p2c2 = p2c2(:, idx(1));
    [clist_all, p2c_all] = append_clist(clist_all, p2c_all, clist2, p2c2);
end

valid_idx = prune_repeat_contours(p2c_all, max_overlap_ratio);
l_order = test_cts.pixel_order(1:numel(find(test_cts.is_loop)));
if (size(l_order, 1)>1)
    l_order = l_order';
end
test_cts2.pixel_order = [clist_all(valid_idx), l_order];


function valid_idx = prune_repeat_contours(p2c, max_overlap_ratio);

if (size(p2c, 2) <= 1)
    valid_idx = 1:size(p2c, 2);
    return;
end
% TODO: make it more robust

p2c = double(p2c>0);
len = (sum(p2c))';
iset = p2c'*p2c;
m = size(iset, 1);

len_m = repmat(len, [1, m]);
len_m = max(len_m, len_m');
iset = iset ./ len_m;

valid_idx = [];
for ii = 1:m
    idx = find(iset(ii, 1:(ii-1)) >= max_overlap_ratio);
    if (isempty(idx))
        valid_idx = [valid_idx; ii];
    end
end

function [clist2, p2c2] = bfs_extend(clist, test_cts, p2c_e, p2c, is_jct, min_overlap, max_overlap_ratio);

clist_new = [];
p2c_e_new = [];
clist2 = [];
p2c2 = [];

% Find extendable contours in the queue
for ii = 1:length(clist)
    pid = clist{ii};
    
    % Extend once
    [clist_tmp, p2c_e_tmp, old_eid] = find_all_extensions(pid, p2c_e(:, ii), p2c, ...
        test_cts, min_overlap);
    if (isempty(clist_tmp))
        [clist2, p2c2] = append_clist(clist2, p2c2, pid, p2c_e(:, ii));
        continue;
    end
    
    % Check if passing junction points
    to_expand = ones(length(clist_tmp), 1);
    for jj = 1:length(clist_tmp)
        idx_jct = find(is_jct(clist_tmp{jj}(old_eid(jj)+1:end)));
        if (~isempty(idx_jct))
            clist_tmp{jj} = clist_tmp{jj}(1:(old_eid(jj)+idx_jct(1)));
            idx = find(p2c_e_tmp(:, jj) > old_eid(jj)+idx_jct(1));
            p2c_e_tmp(idx, jj) = 0;
            to_expand(jj) = 0;
            [clist2, p2c2] = append_clist(clist2, p2c2, clist_tmp(jj), p2c_e_tmp(:, jj));
        end
    end
    idx = find(to_expand);
    if (~isempty(idx))
        [clist_new, p2c_e_new] = append_clist(clist_new, p2c_e_new, clist_tmp(idx), p2c_e_tmp(:, idx));
    end
end

% Combine repeating ones
valid_idx = prune_repeat_contours(p2c_e_new, 1);
clist_new = clist_new(valid_idx);
p2c_e_new = p2c_e_new(:, valid_idx);

if (~isempty(clist_new))
    [clist3, p2c3] = bfs_extend(clist_new, test_cts, p2c_e_new, p2c, is_jct, min_overlap, max_overlap_ratio);
    [clist2, p2c2] = append_clist(clist2, p2c2, clist3, p2c3);
    if (isempty(p2c2))
        return;
    end
end

% Combine repeating ones
valid_idx = prune_repeat_contours(p2c2, max_overlap_ratio);
clist2 = clist2(valid_idx);
p2c2 = p2c2(:, valid_idx);


function [clist1, p2c1] = append_clist(clist1, p2c1, clist2, p2c2);
if (iscell(clist2))
    clist1 = [clist1, clist2];
else
    clist1{end+1} = clist2;
end
p2c1 = [p2c1, p2c2];


function [clist, idx] = sort_clist_by_len(clist);
len = zeros(length(clist), 1);
for ii = 1:length(clist)
    len(ii) = length(clist{ii});
end
[dummy, idx] = sort(len, 'ascend');
clist = clist(idx);
