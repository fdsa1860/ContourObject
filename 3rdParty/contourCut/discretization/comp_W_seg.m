function [W_seg, s2p, s2b] = comp_W_seg(W_adj2, segs, bins, eig_vec)
% [W_seg, s2p, s2b] = comp_W_seg(W_adj, segs, bins);

nb_segs = full(max(segs));
nb_bins = full(max(bins));
nb_pix = full(size(bins, 1));

sj = find(segs);
si = segs(sj);

% Construct adjacency matrix
s2p = sparse(si, sj, 1, nb_segs, nb_pix);
l2p = double(s2p(:, 1:end/2) | s2p(:, (end/2+1):end));
W_seg = l2p * W_adj2 * l2p';

% Construct sequence order matrix
[seg_id, ind] = unique(si);
bin_id = bins(sj(ind));
s2b = sparse(seg_id, bin_id, 1, nb_segs, nb_bins);
s2bt = sparse(bin_id, seg_id, 1, nb_bins, nb_segs);
B = sparse(diag(ones(nb_bins, 1)) + ... % Self-connection
    diag(ones(nb_bins-1, 1), 1) + ... % Connection to next bin
    diag(ones(nb_bins-2, 1), 2) + ... % Connection to next next bin
    diag(1, 1-nb_bins)) + ...
    diag([1 1], 2-nb_bins);
% 
% B = sparse(diag(ones(nb_bins, 1)) + ... % Self-connection
%     diag(ones(nb_bins-1, 1), 1) + ... % Connection to next bin
%     diag(1, 1-nb_bins));

W_clk = s2b * B * s2bt;
W_seg = double(W_seg .* W_clk > 0);


% There still might be loops within bins, so deal with that now
% We only want connections between segments when they don't overlap in
% angle and the connection should only be in one direction.

% For each bin
for bin = 1:nb_bins
    % Get the indices of segments in this bin
    ind = find(bin_id==bin);
    
    if numel(ind) < 2
        continue
    end
    % Calculate the mean of angles
    [row col] = find(s2p(ind,:));
    ang = angle(eig_vec(col));
    ang = accumarray(row, ang, [], @mean);

    % Make the links only go forward
    ang = repmat(ang, [1 numel(ang)]) - repmat(ang', [numel(ang) 1]);
    ang(ang < -2*pi) = ang(ang < -2*pi) + 2*pi;
    ang(ang > 2*pi) = ang(ang > 2*pi) -  2*pi;
    ang_expand = -inf(size(W_seg));
    ang_expand(ind,ind) = ang;
    badinds = find(ang_expand>-1e-3);
    W_seg(badinds) = 0;
%     W_seg(ind, ind) = W_seg(ind, ind) .* double(ang < 0);
    
%     
%     % Get the angles of the nodes
%     [row col] = find(s2p(ind,:));
%     ang = angle(eig_vec(col));
%     
%     % Get the pair-wise angles
% %     tic;ang = repmat(ang, [1 size(ang,1)]) - repmat(ang', [size(ang,1) 1]);toc;
% %     tic;ang = ang(:, ones(size(ang,1),1)) - ang(:, ones(size(ang,1),1))';toc;
%     ang = bsxfun(@minus, ang(:, ones(size(ang,1),1)), ang'); 
%     ang(ang < -2*pi) = ang(ang < -2*pi) + 2*pi;
%     ang(ang > 2*pi) = ang(ang > 2*pi) - 2*pi;
%     
%     % Get the sign matrix
%     s = sign(ang);
%     
%     h = histc(row, 1:max(row));
%     % For each segment
%     for seg1 = 1:numel(ind)
%         s1 = s(row==seg1,:);    
% %         r = row(:,ones(size(s1,1),1));
%         r = repmat(row, [1 size(s1,1)])';
%         s1 = s1(:);
%         r = r(:);
%         acc = accumarray(r, s1);
%         
%         h1 = size(s,1) * h;
%         W_seg(ind(seg1),ind) = double((abs(acc)==h1) & (sign(acc)==-1));
%         W_seg(ind,ind(seg1)) = double((abs(acc)==h1) & (sign(acc)==1));
%         
% %         for seg2 = 1:numel(ind)
% %             % Get the pair-wise angles for just these bins
% %             s2 = s1(:,r==seg2);
% %             
% %             if ~(all(s2(:) == 1)) && ~(all(s2(:) == -1))
% %                 % If all the angles diffs are not the same sign, the segments
% %                 % overlap and there should be no weight between them
% %                 W_seg(ind(seg1), ind(seg2)) = 0;
% %                 W_seg(ind(seg2), ind(seg1)) = 0;
% %             else
% %                 % The weights should only go one way
% %                 W_seg(ind(seg2), ind(seg1)) = double(all(s2(:) == 1));
% %                 W_seg(ind(seg1), ind(seg2)) = double(all(s2(:) == -1));
% %             end
% %         end
%     end
end

% Remove self-link
W_seg = spdiags(zeros(nb_segs, 1), 0, W_seg);

