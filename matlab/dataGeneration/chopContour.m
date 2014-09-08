% chop the contour trajectories into contour segments with the same length

function [segment, segment_id] = chopContour(X, length)

n = numel(X);
nseg = 1;

for i = 1:n
    L = size(X{i}, 1);
    for j = 1:length:L
        L_left = L - j + 1;
        if L_left < length
            break;
        end
        segment{nseg} = X{i}(j:j+length-1, :);
        segment_id(nseg) = i;
        nseg = nseg + 1;        
    end    
end

end