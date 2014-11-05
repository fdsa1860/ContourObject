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
 
% compute the length of the input curve
d = sqrt(sum(diff(data).^2,2));
L = cumsum([0;d]);

if mode == 1
    step = fixed;
elseif mode == 2
    step = L(end) / fixed;
end

n = length(L);
index(1) = 1;
m = 1;
for i = 2:n
    if L(i) >= m * step
        index(m+1) = i;
        m = m + 1;
    end
end

out = data(index,:);

 end