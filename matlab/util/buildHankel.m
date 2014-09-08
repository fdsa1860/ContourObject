% build the Hankel matrix with the input feature
% Output:
%    H: Hankel matrix
%    HHp: the normalized Hankel matrix
%    HHp = (H * H') / norm(H * H', 'fro') when mode == 1
%    HHp = (H' * H) / norm(H' * H, 'fro') when mode == 2 

function [H, HHp] = buildHankel(data, h_size, mode)

dim = size(data, 2);
if mode == 1
    if dim == 1
        H = hankel(data(1:h_size), data(h_size:end));    
    elseif dim == 2
        H_x = hankel(data(1:h_size, 1), data(h_size:end, 1));
        H_y = hankel(data(1:h_size, 2), data(h_size:end, 2));
        H = [H_x; H_y];
    end
elseif mode == 2
    m = size(data, 1);
    row = m - h_size + 1;
    if dim == 1
        H = hankel(data(1:row), data(row:end));    
    elseif dim == 2
        H_x = hankel(data(1:row, 1), data(row:end, 1));
        H_y = hankel(data(1:row, 2), data(row:end, 2));
        H = [H_x; H_y];
    end
    H = H';
end

HHp = (H * H') / norm (H * H', 'fro');

end