function res_info2 = copy_res_info(res_info, idx);
% res_info2 = copy_res_info(res_info, idx);

nb_pix = size(res_info.s2p{1}, 2);
pid = zeros(nb_pix, 1);

res_info2 = res_info;
res_info2.loop_id = cell(length(idx), 1);

for ii = 1:length(res_info2.ind)
    res_info2.is_cycle{ii} = sparse(1, nb_pix);
end

res_info2.eig_id = res_info.eig_id(idx);
% For compatibility
if (isfield(res_info, 'e_area'))
    res_info2.e_area = res_info.e_area(idx);
end
if (isfield(res_info, 'pixel_order'))
    res_info2.pixel_order = cell(length(idx), 1);
    for ii = 1:length(idx)
        res_info2.pixel_order{ii} = res_info.pixel_order{idx(ii)};
    end
end
if (isfield(res_info, 'endpts'))
    res_info2.endpts = res_info.endpts(idx, :);
end


for ii = 1:length(idx)
    jj = res_info2.eig_id(ii);
    res_info2.loop_id{ii} = res_info.loop_id{idx(ii)};
    [dummy, pix] = find(res_info2.s2p{jj}(res_info2.loop_id{ii}, :));
    res_info2.is_cycle{jj} = res_info2.is_cycle{jj} + ...
        sparse(1, pix, 1, 1, nb_pix);
end
