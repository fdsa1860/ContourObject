% Calculate the dynamic distances between any two Hankel matrices
% Input:
%    HHp: the normalized Hankel matrix
%    index: determine which ones as the referent index and then
%              calculate the distances between the referent index and others
%    sigma: the singular values of the hankel matrices
%    alpha: the weight of the order difference in the distance metric
% Output:
%    D: the distance matrix

function D = dynamicDistanceSigma(HHp, index, sigma, alpha)

if nargin < 4
    alpha = 1;
end
if nargin < 3
    sigma = [];
end

n = numel(HHp);
m = numel(index);
D = zeros(m, n);

for i = 1:m
    for j = 1:n
        if isempty(sigma)
            D(i, j) = abs(2 - norm(HHp{i} + HHp{j}, 'fro'));
        elseif all(sigma(:,index(i)) == 0) || all(sigma(:,j) == 0)
            D(i, j) = 0;
        else
            D(i, j) = abs(2 - norm(HHp{i} + HHp{j}, 'fro'));
        end
        D(i, j) = D(i, j) + alpha * norm(sigma(:, index(i)) - sigma(:, j));
    end
end

end