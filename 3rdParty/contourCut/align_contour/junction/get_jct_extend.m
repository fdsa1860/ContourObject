function [jct_id, branch_info] = get_jct_extend(test_cts);
% [jct_id, branch_info] = get_jct_extend(test_cts);

max_radius = 8;
max_angle_diff = pi/8;
min_dist_end = 1;
nb_nei = 8;

x = test_cts.x(:,1);
y = test_cts.y(:,1);
n = length(test_cts.pixel_order);
np = length(x);

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

if (~isfield(test_cts, 'is_loop'))
    test_cts = find_loop(test_cts);
end

% Find extendable endpoints
is_extendable = -ones(n, 2);
for ii = 1:n
    if (test_cts.is_loop(ii))
        is_extendable(ii, :) = 0;
        continue;
    end
    pid = test_cts.pixel_order{ii};
    idx1 = find(p2c(pid(1), :));
    idx1(find(idx1==ii)) = [];
    idx2 = find(p2c(pid(end), :));
    idx2(find(idx2==ii)) = [];
    
    % First
    if (isempty(idx1))
        is_extendable(ii, 1) = 1;
    else
        for jj = 1:length(idx1)
            kk = idx1(jj);
            if (p2c(pid(1), kk)-1 >= min_dist_end && ...
                len(kk)-p2c(pid(1), kk) >= min_dist_end)
                is_extendable(ii, 1) = 0;
            end
        end
        if (is_extendable(ii, 1) < 0)
            is_extendable(ii, 1) = 1;
        end
    end
    
    % Last    
    if (isempty(idx2))
        is_extendable(ii, 2) = 1;
    else
        for jj = 1:length(idx2)
            kk = idx2(jj);
            if (p2c(pid(end), kk)-1 >= min_dist_end && ...
                len(kk)-p2c(pid(end), kk) >= min_dist_end)
                is_extendable(ii, 2) = 0;
            end
        end
        if (is_extendable(ii, 2) < 0)
            is_extendable(ii, 2) = 1;
        end    
    end
end

idx_ept = [find(is_extendable(:,1)); find(is_extendable(:,2))+n];

% Find intersections
jct_id = [];
branch_info = [];
ids = find(sum(p2c, 2));
imap = sparse(y(ids), x(ids), ids, test_cts.imgh, test_cts.imgw);

% % Debug
% figure;
% draw_contours(test_cts, 1:n, 'g.');
% hold on;
for ii = 1:length(idx_ept)
    cid = mod(idx_ept(ii)-1, n)+1;
    pid = test_cts.pixel_order{cid};
    if (length(pid) <= nb_nei)
        continue;
    end
    if (idx_ept(ii) > n)
        pid = pid(end:-1:1);
    end
    ori = comp_contour_ori2(x(pid(1:nb_nei+1)), y(pid(1:nb_nei+1)), nb_nei);
    iid = find_intersection(pid(1), ori(1)+pi, cid, x, y, p2c, imap, ...
        max_radius, max_angle_diff);
    if (~isempty(iid))
        jct_id = [jct_id; iid];
        branch_info = [branch_info; cid];
    end
%     jct_id = [jct_id; pid(1)];
%     plot(x(pid(1)), y(pid(1)), 'r.');
%     quiver(x(pid(1)), y(pid(1)), cos(ori(1)+pi), sin(ori(1)+pi), 'r', 'LineWidth', 2);
end


function iid = find_intersection(pid, ori, cid, x, y, p2c, imap, radius, max_diff);

cx = x(pid);
cy = y(pid);
xbd = [max(cx-radius, 1), min(cx+radius, size(imap, 2))];
ybd = [max(cy-radius, 1), min(cy+radius, size(imap, 1))];
nei_map = imap(ybd(1):ybd(2), xbd(1):xbd(2));
nei_pid = nei_map(find(nei_map));
px = x(nei_pid);
py = y(nei_pid);

theta = atan2(py-cy, px-cx);
delta = abs(angle_diff(theta, ori));
d = sqrt((py-cy).^2+(px-cx).^2);
valid_idx = find(delta <= max_diff+atan2(1, d) & d<=radius);
valid_idx(find(p2c(nei_pid(valid_idx), cid))) = [];     % Remove the contour itself
nei_pid2 = nei_pid(valid_idx);

if (isempty(valid_idx))
    iid = [];
    return;
end
[dummy, min_id] = min(d(valid_idx));
min_cid = find(p2c(nei_pid2(min_id), :));
idx = find(sum(p2c(nei_pid2, min_cid), 2));
[dummy, min_id2] = min(delta(valid_idx(idx)));
iid = nei_pid2(idx(min_id2));

% nei_map2 = sparse(y(nei_pid2)-ybd(1)+1, x(nei_pid2)-xbd(1)+1, 1, ybd(2)-ybd(1)+1, xbd(2)-xbd(1)+1);
