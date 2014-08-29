function [pixel_order, px, py] = gen_contour_order3(l2p, pid, x, y, max_gap, endpts, W_adj);

% New version to compute pixel order in the contour, a bit hacking

nb_pix = size(l2p, 2);
x = x(1:nb_pix, 1);
y = y(1:nb_pix, 1);
endp = mod(endpts-1, nb_pix)+1;

% Compute distance matrix
imgh = max(y);
imgw = max(x);
if (nargin < 7)
    [si,sj] = mex_img2ij([imgh, imgw], max_gap, 1, y(pid)+(x(pid)-1)*imgh);
    val = sqrt((x(pid(si))-x(pid(sj))).^2+(y(pid(si))-y(pid(sj))).^2);
    W_dist = sparse(double(si), double(sj), val, length(pid), length(pid));
else
    W_dist = W_adj(pid, pid);
end
px = x(pid);
py = y(pid);
    
if (endpts(1) > 0)
    % Valid endpts
    end_id = find(pid==endp(1));
    end_id = find_farthest_pt(W_dist, end_id(1));
    [dummy, dist] = find_farthest_pt(W_dist, end_id);
    [dummy, pixel_order] = sort(dist, 'ascend');
    pixel_order = pid(pixel_order);
end

if (endpts(1) < 0)
    % Cycle
    try    
        [dummy, id] = max(sum(l2p, 2));

        % Find one endpt first
%         l2p = [l2p(id:end, :); l2p(1:(id-1), :)];
        k = size(l2p, 1);
        l2p = l2p([id:end, 1:(id-1)], :);
        seg_id = max(spmtimesd(l2p,1:k,[]));
        if isempty(find(seg_id==1, 1))
            error('Gap filling failed.');
        end
        pid2 = find(seg_id);
        [dummy, idx] = sort(full(seg_id(pid2)), 'ascend');
        pid2 = pid2(idx);
        m = length(find(seg_id(pid2)==1));
        n = length(pid2);
        nb_segs = size(l2p, 1);

        W_conn = W_adj(pid2, pid2);
        
        end_id = m+find_farthest_pt(W_conn((m+1):end, (m+1):end), round((n-m)/2));
        S = sparse(seg_id(pid2), 1:n, 1, nb_segs, n);
        C = sparse(diag(ones(nb_segs, 1), 0)+diag(ones(nb_segs-1, 1), 1)+diag(1, 1-nb_segs));
        W_fwd = S' * C * S;
        if (seg_id(pid2(end_id)) == k)
            W_fwd(end_id, seg_id(pid2) == k) = 0;
            W_fwd = sparse(W_fwd);
        end
        
        % Compute distance from that endpt
        [dummy, dist] = find_farthest_pt((W_conn.*W_fwd)', end_id);
        [dummy, pixel_order] = sort(dist, 'ascend');
        pixel_order = pid2(pixel_order);
    catch
    %    if ~isempty(strfind(lasterr, 'Gap filling failed.'))
             warning('Loop failed.\n');
            % Undetermined
            [dummy, start_id] = min((px-mean(px)).^2+(py-mean(py)).^2);
            end_id = find_farthest_pt(W_dist, start_id);
            [dummy, dist] = find_farthest_pt(W_dist, end_id);
            [dummy, pixel_order] = sort(dist, 'ascend');
            pixel_order = pid(pixel_order);
     %   end
    end
end

if (endpts(1) == 0)
    % Undetermined
    [dummy, start_id] = min((px-mean(px)).^2+(py-mean(py)).^2);
    end_id = find_farthest_pt(W_dist, start_id);
    [dummy, dist] = find_farthest_pt(W_dist, end_id);
    [dummy, pixel_order] = sort(dist, 'ascend');    
    pixel_order = pid(pixel_order);
end

return
