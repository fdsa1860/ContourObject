% chop the contour trajectories at corners into contour segments
 
function segment = chopContourAtCorner(contour, corners_index)

r = 1;            % the radius of influence of corners
count = 1;
segment = {};

for i = 1:numel(corners_index)
    numCorner = numel(corners_index{i});
    if numCorner == 0
        segment{count} = contour{i}(r:end-r, :);
        count = count + 1;
    else
        for j = 1:numCorner+1            
            if j == 1
                segment{count} = contour{i}(r:corners_index{i}(j)-r, :); 
            elseif j <= numCorner
                segment{count} =...
                      contour{i}(corners_index{i}(j-1)+r:corners_index{i}(j)-r, :);
            else
                segment{count} = contour{i}(corners_index{i}(j-1)+r:end-r, :);
            end
            
            if size(segment{count}, 1) < 20
                continue;
            else
                count = count + 1;
            end
            
        end       
    end 
end

end