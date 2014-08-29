function [rorder, is_line] = fix_pixel_order(res_info, x, y, ind);
% [rorder, is_line] = fix_pixel_order(res_info, x, y, ind);

% Updated: handling errors

if (~exist('max_gap', 'var'))
    max_gap = 3;
end
if (~exist('ind', 'var'))
    ind = 1:length(res_info.pixel_order);
end

pixel_order = res_info.pixel_order;
if (isfield(res_info, 'endpts'))
    endpts = res_info.endpts;
else
    endpts = zeros(length(pixel_order), 2);
end
nb_contours = length(ind);

x = round(x(:,1));
y = round(y(:,1));

rorder = cell(nb_contours, 1);
is_line = zeros(nb_contours, 1);

for jj = nb_contours:-1:1
    ii = ind(jj);
    % Check pixel_order first. If any(nei_dist>max_gap*2), bad loop
    px = x(pixel_order{ii});
    py = y(pixel_order{ii});
    
    if (endpts(ii, 1) == -1)
        % Loop
        
        % Find out the largest piece first
        s2p = res_info.s2p{res_info.eig_id(ii)}(res_info.loop_id{ii}(1), :);
        seg_idx = find(s2p(:, 1:end/2) | s2p(:, end/2+1:end));
        for kk = 2:length(res_info.loop_id{ii})
            s2p = res_info.s2p{res_info.eig_id(ii)}(res_info.loop_id{ii}(kk), :);
            idx = find(s2p(:, 1:end/2) | s2p(:, end/2+1:end));
            if (length(idx) > length(seg_idx))
                % Longer
                seg_idx = idx;
            end
        end
        px = x(seg_idx);
        py = y(seg_idx);
        [dummy, mid_id] = min((px-mean(px)).^2+(py-mean(py)).^2);
        rorder{jj} = comp_loop_order(pixel_order{ii}, x, y, max_gap, seg_idx(mid_id));
        
        % Double check: bad loop
        if (isempty(rorder{jj}))
            rorder{jj} = comp_line_order(pixel_order{ii}, x, y, max_gap, -1);
            is_line(jj) = 1;
        end
    else
        % Line
        rorder{jj} = comp_line_order(pixel_order{ii}, x, y, max_gap, -1);
        is_line(jj) = 1;
    end
    if (isempty(rorder{jj}))
        rorder = rorder([1:jj-1 jj+1:end]);
    end
end


