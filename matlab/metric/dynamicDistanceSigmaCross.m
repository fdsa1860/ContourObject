function D = dynamicDistanceSigmaCross(HHp1, HHp2, sigma1, sigma2, alpha)

if nargin < 5
    alpha = 1;
end
if nargin < 3
    sigma1 = [];
    sigma2 = [];
end

m = numel(HHp1);
n = numel(HHp2);
D = zeros(m, n);

for i = 1:m
    for j = 1:n
        if isempty(sigma1) || isempty(sigma2)
            D(i, j) = abs(2 - norm(HHp1{i} + HHp2{j}, 'fro'));
        elseif all(sigma1(:, i) == 0) || all(sigma2(:, j) == 0)
            D(i, j) = 0;
        else
            D(i, j) = abs(2 - norm(HHp1{i} + HHp2{j}, 'fro'));
        end
        D(i, j) = D(i, j) + alpha * norm(sigma1(:, i) - sigma2(:, j));
    end
end

end