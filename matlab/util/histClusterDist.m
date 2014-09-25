function h = histClusterDist(D, labels, centerInd, show)

nc = length(centerInd);
h = cell(1, nc);
t = 0:0.1:2;
for i = 1:nc
    y = centerInd(i);
    d = D(y, labels==i);
    h{i} = hist(d,t);
end

if show
    colorseq = 'bgrmcykbgrmcykbgrmcyk';
    figure;
    hold on;
    for i = 1:length(h)
        plot(t, h{i}, colorseq(i));
    end
    hold off;
end

end