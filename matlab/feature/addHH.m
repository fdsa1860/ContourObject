function seg = addHH(seg, hankelSize)

if isempty(seg), seg().H = []; seg().HH = []; return; end

numSeg = length(seg);
for i = 1:numSeg
%     seg(i).vel = complex(seg(i).vel(:,1), seg(i).vel(:,2)); % using complex number
    if nargin==1
        % H = hankel_mo(seg(i).vel');
        H = mexHankel(seg(i).vel');
    elseif nargin==2
%         m = floor(hankelSize/2);
%         n = size(seg(i).vel, 1) - hankelSize/2 + 1;
        n = hankelSize;
        m = size(seg(i).vel, 1) - hankelSize + 1;
%         H = hankel_mo(seg(i).vel', [size(seg(i).vel, 2)*m n]);
        H = mexHankel(seg(i).vel', [size(seg(i).vel, 2)*m n]);
%         Hx = mexHankel(seg(i).vel(:,1)', [m n]);
%         Hy = mexHankel(seg(i).vel(:,2)', [m n]);
    end
%     HH = (H * H') / norm (H * H', 'fro');
    HH = (H' * H) / norm (H' * H, 'fro');
%     HHx = (Hx' * Hx) / norm (Hx' * Hx, 'fro');
%     HHy = (Hy' * Hy) / norm (Hy' * Hy, 'fro');
    seg(i).H = H;
    seg(i).HH = HH;
%     seg(i).HHx = HHx;
%     seg(i).HHy = HHy;
end

end