function sigma = sigmaEst(H, isLine)
% Input:
% H: 1 by N cell array, each cell contains a hankel matrix
% Output:
% sigma: D by N matrix, each column contains normalize singular value
% vector

if nargin < 2 || isempty(isLine)
    isLine = false(1, length(H));
end

numSeg = length(H);
ind = ~cellfun(@isempty, H);
hankelSize = size(H{ind(1)}, 1);
sigma = zeros(hankelSize, numSeg);
for i = 1:numSeg
    if isempty(H{i}) || isLine(i);
        continue;
    end
    s = svd(H{i});
    sigma(:, i) = s./s(1);
end

end