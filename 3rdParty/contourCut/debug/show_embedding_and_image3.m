function show_embedding_and_image3(img, embedding, x, y)

figure;
hold on;

emb = scatter(real(embedding), imag(embedding), 10*ones(numel(embedding),1),'*');

title('Complex Embedding');
xlabel('\Re');
ylabel('\Im');

fig = figure;
ah = axes();
set(fig,'WindowButtonMotionFcn', @func);
imagesc(img);
hold on;
edg = scatter(x(:,1), y(:,1), 10, zeros(numel(x(:,1)),1),'.');
colormap(lines);


    function func(src,evnt)
        cp = get(ah,'CurrentPoint');
        D = ipdm(cp(1,1:2), [x(:,1) y(:,1)]);
        mind = min(D);
        inds = D==mind;
        colors = get(edg, 'cdata');
        colors = 0*colors;
        colors(inds) = 20;
        set(edg, 'cdata', colors);
        set(edg, 'sizedata', colors+10);
        
        set(emb, 'sizedata', [colors+10; colors+10]);
        set(emb, 'cdata', [2*ones(size(x,1),1); 10*ones(size(x,1),1)] + [colors; colors]);
        
        drawnow
        
    end

end