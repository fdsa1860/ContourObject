function D = dynamicDistanceSigmaCross(X, centers, alpha)

if nargin < 3
    alpha = 1;
end

m = numel(X);
n = numel(centers);
D = zeros(m, n);

for i = 1:m
    for j = 1:n
        if isempty(X(i).sigma) || isempty(centers(j).sigma)
            try
            D(i, j) = abs(2 - norm(X(i).HH + centers(j).HH, 'fro'));
            catch me, keyboard; end
        elseif all(X(i).sigma == 0) || all(centers(j).sigma == 0)
            D(i, j) = 0;
        else
            D(i, j) = abs(2 - norm(X(i).HH + centers(j).HH, 'fro'));
        end
        D(i, j) = D(i, j) + alpha * norm(X(i).sigma - centers(j).sigma);
    end
end

end