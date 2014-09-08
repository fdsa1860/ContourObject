% Get the rank of the Hankel matrix 

function order_info = getOrder(H, t)

S = svd(H);
c = 0;
e = sum(S);
for i = 1:numel(S)
    c = c + S(i);
    r = c / e;
    if r > t
        break;
    end    
end

order_info = i;

end