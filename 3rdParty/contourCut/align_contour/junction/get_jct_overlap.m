function [jct_id, branch_info] = get_jct_overlap(test_cts);
% [jct_id, branch_info] = get_jct_overlap(test_cts);

min_overlap = 5;
% max_gap_on_cont = 8;
min_dist_end = 5;

n = length(test_cts.pixel_order);
np = length(test_cts.x);

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

jct_id = [];
branch_info = [];
for ii = 1:n
    pid = test_cts.pixel_order{ii};
    [si, sj] = find(p2c(pid, :));
    sj = unique(sj);
    sj(find(sj<=ii)) = [];
    for jj = 1:length(sj)
        kk = sj(jj);
        common_id = find(p2c(:,ii) & p2c(:,kk));
%         jct_id2 = get_jct_id(p2c(:,ii), p2c(:,kk), common_id);
        
        % Find possible junction positions
        if (length(common_id) < min_overlap)
            continue;
        end
        % Sort
        [id1, idx1] = sort(full(p2c(common_id, ii)), 'ascend');
        [id2, idx2] = sort(full(p2c(common_id, kk)), 'ascend');
        if (sum(abs(idx1-idx2)) > sum(abs(idx1-idx2(end:-1:1))))
            % Reverse order
            idx2 = idx2(end:-1:1);
            id2 = len(kk)+1-id2(end:-1:1);
        end
        cid1 = common_id(idx1);
        cid2 = common_id(idx2);
        
        % Add endpts of common parts
        jct_id2 = [];
        if (id1(1)-1>=min_dist_end && id2(1)-1>=min_dist_end)
            jct_id2 = cid1(1);
        end
        if (len(ii)-id1(end)>=min_dist_end && len(kk)-id2(end)>=min_dist_end)
            jct_id2 = [jct_id2; cid1(end)];
        end

%         % Add endpts from jumping
%         id_jump1 = find(cid1(3:end-1)-cid1(2:end-2)>max_gap_on_cont); % Exclude the endpts
%         id_jump2 = find(cid2(3:end-1)-cid2(2:end-2)>max_gap_on_cont);
%         id_jump1 = [];
%         id_jump2 = [];
%         jct_id2 = [jct_id2; cid1([id_jump1+1; id_jump1+2]); cid2([id_jump2+1; id_jump2+2])];

%         jct_id = [jct_id; unique(jct_id2)];
        jct_id = [jct_id; jct_id2];
        branch_info = [branch_info; repmat([ii, kk], [length(jct_id2), 1])];
    end
end


% function jct_id = get_jct_id(p2c1, p2c2, common_id)

