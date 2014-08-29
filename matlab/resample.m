% Resample the synthetic data with fixed step or fixed points
% Input:
%    data:the original data produced by MATLAB
%    mode: resampling with fixed step (== 1)
%               resampling with fixed points (== 2)
%    fixed: the value of resampling step (mode == 1)
%             the number of resampling points (mode == 2)         
% Output:
%    out: the data after resampled

function out = resample(data, mode, fixed)

x = data(:, 1);
y = data(:, 2);
n = numel(x);

% compute the length of the input curve
L(1) = 0;
for i = 2:n
    L(i) = L(i-1) + sqrt((x(i) - x(i-1)).^2 + (y(i) - y(i-1)).^2);
end

if mode == 1
    step = fixed;
elseif mode == 2
    step = L(end) / fixed;
end

index(1) = 1;
m = 1;
for i = 2:n
    if L(i) >= m * step
        index(m+1) = i;
        m = m + 1;
    end
end

out(:, 1) = x(index);
out(:, 2) = y(index);

end














