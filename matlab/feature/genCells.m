function cells = genCells(win, sbin)
% Input:
% win: window's bounding box, [xTopLeft yTopLeft xBottomRight yBottomRight]
% nc: number of column blocks
% nr: number of row blocks
% Output:
% cells: a structure data which contains info for cells locations
% bbox: n by 4 matrix, each row is a bounding box [xTopLeft yTopLeft
% xBottomRight yBottomRight]
% nr: number of rows
% nc: number of columns
% num: number of cells

width = win(3) - win(1) + 1;
height = win(4) - win(2) + 1;
nc = round(width/sbin);
nr = round(height/sbin);
% nc = round(width/sbin)-2;
% nr = round(height/sbin)-2;
bbox = zeros(nr*nc, 4);
for i = 1:nr
    for j = 1:nc
        bbox((i-1)*nc+j, :) = [(j-1)*sbin+1, (i-1)*sbin+1, ...
            min(j*sbin,width), min(i*sbin,height)];
    end
end

bbox = bsxfun(@plus, bbox, [win(1)-1 win(2)-1 win(1)-1 win(2)-1]);

cells.bbox = bbox;
cells.nr = nr;
cells.nc = nc;
cells.num = nr * nc;

end