function [clist, p2c_e, old_eid] = find_all_extensions(pid, p2c_1, p2c, test_cts, min_overlap);

max_gap = 3;

cid = find(p2c(pid(end), :));
clist = [];
old_eid = [];
si = [];
sj = [];
val = [];
for ii = 1:length(cid)
    jj = cid(ii);
    if (test_cts.is_loop(jj))
        continue;
    end
    pid2 = test_cts.pixel_order{jj};
    nb_overlap = sum(p2c_1(pid2)>0);
    if (nb_overlap >= min_overlap && pid2(1)~= pid(end) && pid2(end)~= pid(end))
        % Find the right direction to extend
        common_id = find(p2c_1 & p2c(:, jj));
        eid = p2c(pid(end), jj);
        less_sum = sum(p2c(common_id, jj)<eid);
        if (less_sum < length(common_id)/2)
            pid3 = find(p2c_1==0 & p2c(:, jj) & p2c(:, jj)<eid);
        else
            pid3 = find(p2c_1==0 & p2c(:, jj) > eid);            
        end
        pid3 = [pid(end); pid3];
        
        [pid4, dist_test] = comp_line_order(pid3, test_cts.x, test_cts.y, max_gap, 1);
        if (isempty(pid4))
            idx = find(~isinf(dist_test));
            pid4 = comp_line_order(pid3(idx), test_cts.x, test_cts.y, max_gap, 1);
        end
        
        % Recompute order
        pid_new = [pid; pid4(2:end)];
        if (length(pid_new) <= length(pid))
            continue;
        end
        [dummy, eid] = max(p2c_1(pid_new));
        old_eid(end+1) = eid;
        clist{end+1} = pid_new;
        si = [si; pid_new];
        sj = [sj; ones(length(pid_new), 1)*length(clist)];
        val = [val; (1:length(pid_new))'];
    end
end

if (isempty(si))
    p2c_e = [];
else
    p2c_e = sparse(si, sj, val, size(p2c, 1), length(clist));
end