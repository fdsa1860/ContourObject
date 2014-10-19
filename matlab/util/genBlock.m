function block = genBlock(bb, nc, nr)
% Input:
% bb: bounding box, [xTopLeft yTopLeft xBottomRight yBottomRight]
% nc: number of column blocks
% nr: number of row blocks
% Output:
% block: n by 4 matrix, each row is a bounding box [xTopLeft yTopLeft
% xBottomRight yBottomRight]

width = bb(3) - bb(1) + 1;
height = bb(4) - bb(2) + 1;
blockW = floor(width/nc);
blockH = floor(height/nr);
block = zeros(nr*nc, 4);
for i = 1:nr
    for j = 1:nc
        block((i-1)*nc+j, :) = [(j-1)*blockW+1 (i-1)*blockH+1 j*blockW i*blockH];
    end
end

block = bsxfun(@plus, block, [bb(1)-1 bb(2)-1 bb(1)-1 bb(2)-1]);

end