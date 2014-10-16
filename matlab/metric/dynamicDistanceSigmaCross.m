function D = dynamicDistanceSigmaCross(HHp1, sigma1, centers, alpha)

if nargin < 5
    alpha = 1;
end
if nargin < 3
    sigma1 = [];
end

m = numel(HHp1);
n = numel(centers);
D = zeros(m, n);

for i = 1:m
    for j = 1:n
        if isempty(sigma1) || isempty(centers(j).sigma)
            D(i, j) = abs(2 - norm(HHp1{i} + centers(j).HH, 'fro'));
        elseif all(sigma1(:, i) == 0) || all(centers(j).sigma == 0)
            D(i, j) = 0;
        else
            D(i, j) = abs(2 - norm(HHp1{i} + centers(j).HH, 'fro'));
        end
        D(i, j) = D(i, j) + alpha * norm(sigma1(:, i) - centers(j).sigma);
    end
end

end