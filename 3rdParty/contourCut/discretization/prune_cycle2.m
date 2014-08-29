function is_valid = prune_cycle2(seg_id, new_seg_id, nb_segs);

% Prune cycles if they shared most of the segs

is_new = zeros(nb_segs, 1);
is_new(new_seg_id) = 1;
is_valid = 1;
n = length(new_seg_id);

for ii = 1:length(seg_id)
    overlap = sum(is_new(seg_id{ii}));
    if ((overlap/n > 0.7) && (overlap/length(seg_id{ii}) > 0.7))
        is_valid = 0;
        return;
    end
end

