function seg = addHH(seg, hankelSize, option)

if isempty(seg), seg().H = []; seg().HH = []; return; end
if ~exist('option','var'), option = 'HtH'; end

numSeg = length(seg);
for i = 1:numSeg
    if ~exist('hankelSize','var')
        % H = hankel_mo(seg(i).vel');
        H = mexHankel(seg(i).vel');
    else
        if strcmp(option, 'HtH')
            n = hankelSize;
            m = size(seg(i).vel, 1) - hankelSize + 1;
        elseif strcmp(option, 'HHt')
            m = floor(hankelSize/2);
            n = size(seg(i).vel, 1) - hankelSize/2 + 1;
        else
            error('option should either be HtH or HHt\n');
        end
        H = mexHankel(seg(i).vel', [size(seg(i).vel,2)*m n]);
%         Hx = mexHankel(seg(i).vel(:,1)', [m n]);
%         Hy = mexHankel(seg(i).vel(:,2)', [m n]);
    end

    if strcmp(option, 'HtH')
        HH = (H' * H) / norm (H' * H, 'fro');
    elseif strcmp(option, 'HHt')
        HH = (H * H') / norm (H * H', 'fro');
    else
        error('option should either be HtH or HHt\n');
    end
%     HHx = (Hx' * Hx) / norm (Hx' * Hx, 'fro');
%     HHy = (Hy' * Hy) / norm (Hy' * Hy, 'fro');
    seg(i).H = H;
    seg(i).HH = HH;
%     seg(i).HHx = HHx;
%     seg(i).HHy = HHy;
end

end