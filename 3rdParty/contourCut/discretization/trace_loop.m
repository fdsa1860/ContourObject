function loop_id = trace_loop(prev1, prev2, start_id, end_id, inter_id);
% loop_id = trace_loop(prev1, prev2, start_id, end_id, inter_id);
% Find out loop id.

kk = inter_id;
loop_id = [];
while (kk ~= end_id)
    loop_id = [loop_id; kk];
    kk = prev2(kk);
end
kk = inter_id;
while (kk ~= start_id)
    kk = prev1(kk);
    loop_id = [kk; loop_id];
end
loop_id = [loop_id; end_id];
