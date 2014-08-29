function show_embedding_and_image(img, embedding, x, y)

fig = figure;
set(fig,'WindowButtonMotionFcn', @func);
ah = axes();
hold on;

scatter(real(embedding), imag(embedding), 100, [ones(size(x,1),1); 10*ones(size(x,1),1)],'.');
hl = line('XData',0,'YData',0,'Marker','p','color','k');
cp = get(ah,'CurrentPoint');
hm = scatter(cp(1,1), cp(1,2), 'or', 'LineWidth', 2);

title('Complex Embedding');
xlabel('\Re');
ylabel('\Im');

figure;
imagesc(img);
hold on;
hm2 = scatter(0,0,'sg', 'LineWidth', 2);


    function func(src,evnt)
        cp = get(ah,'CurrentPoint');
        xdat = [0,cp(1,1)];
        ydat = [0,cp(1,2)];
        set(hl,'XData',xdat,'YData',ydat);
        drawnow
        
%         %get points with close angle
%         angles = atan2(imag(embedding),real(embedding));
%         angle = atan2(cp(1,2), cp(1,1));
%         valid = abs(repmat(angle, size(angles)) - angles)*180/pi < 5;
        %find closest point
        em2 = embedding;
        d = ipdm(cp(1,1:2), [real(em2), imag(em2)]);
        d = min(d,[],1);
        [junk ind] = min(d);
        set(hm, 'Xdata', real(em2(ind)), 'Ydata', imag(em2(ind)));
        
        %highlight point in the image
        set(hm2, 'Xdata', x(ind), 'Ydata', y(ind));
    end

end