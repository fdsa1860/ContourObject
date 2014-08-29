function test_cts = find_loop(test_cts)

if (isfield(test_cts, 'is_loop'))
    return;
end
if (isfield(test_cts, 'res_info'))
    % Use fix_pixel_order
    [rorder, is_line] = fix_pixel_order(test_cts.res_info, test_cts.x, test_cts.y);
    test_cts.pixel_order = rorder;
    test_cts.is_loop = 1-is_line;
    return;
end

% Pixel based
max_gap = 3;
n = length(test_cts.pixel_order);
test_cts.is_loop = zeros(n, 1);
for ii = 1:n
    pid = test_cts.pixel_order{ii};
    px = test_cts.x(pid);
    py = test_cts.y(pid);
    if (sqrt((px(1)-px(end))^2+(py(1)-py(end))^2)<=max_gap)
        test_cts.is_loop(ii) = 1;
    end
end