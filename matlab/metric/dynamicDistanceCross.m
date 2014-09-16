function D = dynamicDistanceCross(HHp1, HHp2, order_info1, order_info2)

if nargin < 3
    order_info1 = [];
    order_info2 = [];
end

n = numel(HHp1);
m = numel(HHp2);
D = zeros(m, n);

for i = 1:n
    for j = 1:m
        if isempty(order_info1) || isempty(order_info2)
            D(i, j) = abs(2 - norm(HHp1{i} + HHp2{j}, 'fro'));
        elseif order_info1(i) == 0 && order_info2(j) == 0
            D(i, j) = 0;
        else
            D(i, j) = abs(2 - norm(HHp1{i} + HHp2{j}, 'fro'));
        end
        if order_info1(i) ~= order_info2(j)            
            D(i, j) = D(i, j) + 1;
        end
    end    
end

end