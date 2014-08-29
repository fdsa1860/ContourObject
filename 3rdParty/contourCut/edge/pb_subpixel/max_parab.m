function max_x = max_parab(val);

% max_x = zeros(size(val, 1), 1);
[dummy, max_x] = max(val, [], 2);
max_x = max_x - 2;
a = val(:, 1);
b = val(:, 2);
c = val(:, 3);
idx = find(b>a & b>c);
max_x(idx) = (c(idx)-a(idx)) ./ (2*b(idx)-a(idx)-c(idx)) /2;
