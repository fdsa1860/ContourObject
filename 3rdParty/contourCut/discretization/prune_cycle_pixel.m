function res_info2 = prune_cycle_pixel(res_info, method, options);
% res_info2 = prune_cycle_pixel(res_info, method, options);

% Prune by overlap ratio
if (method == 1)
    if (nargin < 3)
        overlap_ratio = 0.5;
    else
        overlap_ratio = options;
    end

    nb_pix = size(res_info.s2p{1}, 2);
    nb_loops = 0;
    pid = zeros(nb_pix/2, 1);
    is_valid = zeros(length(res_info.loop_id), 1);

    for ii = 1:length(res_info.loop_id)
        s2p = res_info.s2p{res_info.eig_id(ii)};
        [dummy, pix] = find(sum(s2p(res_info.loop_id{ii}, 1:end/2)+s2p(res_info.loop_id{ii}, end/2+1:end)));
        if (sum(pid(pix)) < overlap_ratio*length(pix))
            nb_loops = nb_loops + 1;
            is_valid(ii) = 1;
            pid(pix) = 1;
        end
    end

    res_info2 = copy_res_info(res_info, find(is_valid));
end

% Prune if one cover the other
if (method == 2)
    x = options.x;
    y = options.y;
    img_sz = options.img_sz;
    
    if (size(x, 1) ~= size(res_info.s2p{1}, 2))
        x = [x;x];
        y = [y;y];
    end
    x = x(:, 1);
    y = y(:, 1);
    
    nb_loops = length(res_info.loop_id);
    to_copy = [];
    
    % A better way
    nb_pix = length(x)/2;
    l2p = sparse(nb_loops, nb_pix);
    to_delete = [];
    for ii = 1:nb_loops
        s2p = res_info.s2p{res_info.eig_id(ii)};
        % To speed up here...
        l2p(ii, :) = double(sum(s2p(res_info.loop_id{ii}, 1:end/2)+...
            s2p(res_info.loop_id{ii}, end/2+1:end)) > 0);
    end
    W = l2p * l2p';
    for ii = 1:nb_loops
        for jj = ii+1:nb_loops
            if (W(ii, jj) == W(jj, jj))
                to_delete = [to_delete; jj];
                continue;
            end
            if (W(ii, jj) == W(ii, ii))
                to_delete = [to_delete; ii];
            end
        end
    end
    
    to_copy = 1:nb_loops;
    to_copy(to_delete) = [];
    
    res_info2 = copy_res_info(res_info, to_copy);
end

% Prune if the cycle is too small
if (method == 3)

    nb_pix = size(res_info.s2p{1}, 2);
    nb_loops = 0;
    pid = zeros(nb_pix/2, 1);
    is_valid = zeros(length(res_info.loop_id), 1);

    for ii = 1:length(res_info.loop_id)
        if (res_info.ind(res_info.eig_id(ii)) < 300)
            is_valid(ii) = 1;
        end
    end

    res_info2 = copy_res_info(res_info, find(is_valid));
end

% Prune if the cycle is too small
if (method == 4)

    nb_pix = size(res_info.s2p{1}, 2);
    nb_loops = 0;
    pid = zeros(nb_pix/2, 1);
    is_valid = zeros(length(res_info.loop_id), 1);
    max_length = options;
    
    for ii = 1:length(res_info.loop_id)
        s2p = res_info.s2p{res_info.eig_id(ii)}(res_info.loop_id{ii}, :);
        idx = find(sum(s2p(:, 1:end/2)+s2p(:, end/2+1:end)));
        
        if (length(idx) > options)
            is_valid(ii) = 1;
        end
    end

    res_info2 = copy_res_info(res_info, find(is_valid));
end

% Prune if one almost cover the other 
if (method == 5)

    if (nargin < 3)
        overlap_ratio = 0.95;
    else
        overlap_ratio = options;
    end
    
    nx = size(res_info.s2p{1}, 2)/2;
    n = length(res_info.pixel_order);
    si = [];
    sj = [];
    for ii = 1:n
        si = [si; ones(length(res_info.pixel_order{ii}), 1)*ii];
        sj = [sj, res_info.pixel_order{ii}];
    end
    c2p = sparse(si, sj, 1, n, nx);
    c2pt = sparse(sj, si, 1, nx, n);
    c2c = c2p * c2pt;
    % c2c: n*n matrix
    
    is_valid = ones(n, 1);
    for ii = 1:n
        if (max(c2c((ii+1):end, ii)) > overlap_ratio*length(res_info.pixel_order{ii}))
            is_valid(ii) = 0;
        end
    end
    
    res_info2 = copy_res_info(res_info, find(is_valid));
end

% Prune if one almost identical to the other 
if (method == 6)

    if (nargin < 3)
        overlap_ratio = 0.9;
    else
        overlap_ratio = options;
    end
    
    nx = size(res_info.s2p{1}, 2)/2;
    n = length(res_info.pixel_order);
    lens = zeros(n, 1);
    si = [];
    sj = [];
    for ii = 1:n
        lens(ii) = length(res_info.pixel_order{ii});
        si = [si; ones(lens(ii), 1)*ii];
        sj = [sj, res_info.pixel_order{ii}];
    end
    c2p = sparse(si, sj, 1, n, nx);
    c2pt = sparse(sj, si, 1, nx, n);
    c2c = c2p * c2pt;
    % c2c: n*n matrix
    
    is_valid = ones(n, 1);
    for ii = 1:n
        for jj = (ii+1):n
            r1 = c2c(ii,jj) / lens(ii);
            r2 = c2c(ii,jj) / lens(jj);
            if (r1 > overlap_ratio && r2 > overlap_ratio)
                if (r1 > r2)
                    is_valid(ii) = 0;
                else
                    is_valid(jj) = 0;
                end
            end
        end
    end
    
    res_info2 = copy_res_info(res_info, find(is_valid));
end