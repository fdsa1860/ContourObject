function h = histClusterLength(contourPool, labels, centerInd, show)

t = 1:20:400;
nc = length(centerInd);
h = cell(1, nc);
n = length(contourPool);
dp = zeros(1, n);

for i = 1:n
    dp(i) = length(contourPool{i});
end

for i = 1:nc
    y = centerInd(i);
    d = dp(labels == labels(y));
    h{i} = hist(d, t);
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
