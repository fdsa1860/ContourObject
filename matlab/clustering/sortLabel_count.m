function label = sortLabel_count(NcutDiscrete)

% label the data from low order to high order
n = size(NcutDiscrete, 1);
k = size(NcutDiscrete, 2);
label = zeros(n, 1);
index = cell(k, 1);
count = zeros(k, 1);

for i = 1:k
    index{i} = find(NcutDiscrete(:, i));
    count(i) = length(index{i});
end

[~, I] = sort(-count);

for i = 1:k
    label(index{I(i)}) = i;
end

end