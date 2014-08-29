% Handle loop order, need to check embedding space a bit
function [pixel_order2, is_line] = comp_loop_order(pid, x, y, max_gap, start_id);

% Fix the bug if it took line as a loop by mistake. TODO...

pid = pid(:);
px = x(pid);
py = y(pid);
px = px-min(px)+1;
py = py-min(py)+1;
imgh = max(py);
imgw = max(px);

if (start_id == -1)
    start_id = 1;
else
    start_id = find(pid == start_id);
    if (isempty(start_id))
        start_id = 1;
    end
end

% Find a good starting point
is_success = 0;
is_line = 0;
kk = 0;
l = length(pid);
nb_trial = 10;

while (~is_success && kk<=nb_trial)
    idx = find(max(abs(px-px(start_id)), abs(py-py(start_id))) > 2);
    if (isempty(idx))
        break;
    end
    [dummy, end_pid] = min((px(idx)-px(start_id)).^2+(py(idx)-py(start_id)).^2);
    p_order = comp_line_order(idx, px, py, max_gap, end_pid);
    ex = px(idx(end_pid));
    ey = py(idx(end_pid));
    
    % Hit junction, find other starting pts
    if (isempty(p_order))
        start_id = mod(start_id+max(round(l/nb_trial),1)-1, l)+1;
    else
        is_success = 1;
        break;
    end
    kk = kk + 1;
end

if (~is_success)
    warning('Weird loop: cannot find starting point here.');
    pixel_order2 = comp_line_order(pid, x, y, max_gap, -1);
    return;
end

% % Need to pad, a simple way...
% idx2 = find(max(abs(px-px(start_id)), abs(py-py(start_id))) <= 2);
% [dummy, ind] = sort((px(idx2)-ex).^2+(py(idx2)-ey).^2, 'descend');
% p_order2 = idx2(ind);
% pixel_order2 = [pid(p_order); pid(p_order2)];

% Pad: a better way
idx_pad = [find(max(abs(px-px(start_id)), abs(py-py(start_id))) <= 2); p_order(1); p_order(end)];
p_order2 = comp_line_order(idx_pad, px, py, max_gap, length(idx_pad));
idx_end = find(p_order2==idx_pad(end-1));
if (isempty(p_order2) || isempty(idx_end))
    pixel_order2 = [];
    return;
end
pixel_order2 = [pid(p_order); pid(p_order2(2:idx_end-1))];