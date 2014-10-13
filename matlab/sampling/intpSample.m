% Resample the synthetic data with fixed step or fixed points
% Input:
%    data:the original data produced by MATLAB
%    mode: resampling with fixed step (== 1)
%               resampling with fixed points (== 2)
%    fixed: the value of resampling step (mode == 1)
%             the number of resampling points (mode == 2)         
% Output:
%    out: the data after resampled

function out = intpSample(data, mode, fixed)

intpStep = 0.1; % interpolation step

% spline fit the data
func = cscvn(data');
head = func.breaks(1);
tail = func.breaks(end);
intpData = fnval(func,head:intpStep:tail)';

% compute the length of the input curve
d = sqrt(sum(diff(intpData,1,1).^2,2));
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

out = intpData(index,:);

end