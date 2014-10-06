function block = genBlock(width, height, nc, nr)
% Input:
% width: width of the sample image
% height: height of the sample image
% nc: number of column blocks
% nr: number of row blocks
% Output:
% block: n by 4 matrix, each row is a bounding box [xTopLeft yTopLeft
% xBottomRight yBottomRight]

blockW = floor(width/nc);
blockH = floor(height/nr);
block = zeros(nr*nc, 4);
for i = 1:nr
    for j = 1:nc
        block((i-1)*nc+j, :) = [(j-1)*blockW+1 (i-1)*blockH+1 j*blockW i*blockH];
    end
end


end