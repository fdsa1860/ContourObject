function show_embedding_and_image2(img, embedding, x, y)

fig = figure;
set(fig,'WindowButtonMotionFcn', @func);
ah = axes();
hold on;

scatter(real(embedding), imag(embedding), '.b');
hl = line('XData',0,'YData',0,'Marker','p','color','k');
cp = get(ah,'CurrentPoint');
hm = scatter(cp(1,1), cp(1,2), 'or', 'LineWidth', 2);

title('Complex Embedding');
xlabel('\Re');
ylabel('\Im');

figure;
imagesc(img);
colormap(jet);
hold on;
hm2 = scatter(0,0,'og', 'LineWidth', 2);


    function func(src,evnt)
        cp = get(ah,'CurrentPoint');
        xdat = [0,cp(1,1)];
        ydat = [0,cp(1,2)];
        set(hl,'XData',xdat,'YData',ydat);
        drawnow
        
        %get points with close angle
        angles = atan2(imag(embedding),real(embedding));
        angle = atan2(cp(1,2), cp(1,1));
        valid = abs(repmat(angle, size(angles)) - angles)*180/pi < 360/20;
        %get magnitudes
        em2 = embedding(valid);
        mag = sqrt(real(em2).^2 + imag(em2).^2);        
        set(hm, 'Xdata', real(em2), 'Ydata', imag(em2));
        
        %highlight point in the image
        set(hm2, 'Xdata', x(valid), 'Ydata', y(valid), 'SizeData', 200*(mag/max(mag)).^2, 'Cdata', 128*(mag/max(mag)).^2);
    end

end