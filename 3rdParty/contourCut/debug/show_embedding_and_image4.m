function show_embedding_and_image4(img, embedding, x, y)

figure;
hold on;

scatter(real(embedding), imag(embedding),50,'.b');
plt = plot(0,0,'.-g');
plt2 = plot(0,0,'.-r');

title('Complex Embedding');
xlabel('\Re');
ylabel('\Im');

fig = figure;
ah = axes();
imagesc(img);
hold on;
sct = scatter(x(:,1), y(:,1),'bs');
set(sct, 'buttondownfcn', @func);
plt3 =  plot(0,0, '.-g');


firsttime = true;

    function func(src,evnt)
        cp = get(ah,'CurrentPoint');
        D = ipdm(cp(1,1:2), [x(:,1) y(:,1)]);
        [junk ind] = min(D);
        
        if firsttime
            set(plt3, 'xdata', x(ind,1));
            set(plt3, 'ydata', y(ind,1));
            
            set(plt, 'xdata', real(embedding(ind)));
            set(plt, 'ydata', imag(embedding(ind)));
            
            set(plt2, 'xdata', real(embedding(ind+numel(embedding)/2)));
            set(plt2, 'ydata', imag(embedding(ind+numel(embedding)/2)));
            
            firsttime = false;
        else
            set(plt3, 'xdata', [get(plt3, 'xdata') x(ind,1)]);
            set(plt3, 'ydata', [get(plt3, 'ydata') y(ind,1)]);
            
            set(plt, 'xdata', [get(plt, 'xdata') real(embedding(ind))]);
            set(plt, 'ydata', [get(plt, 'ydata') imag(embedding(ind))]);
            
            set(plt2, 'xdata', [get(plt2, 'xdata') real(embedding(ind+numel(embedding)/2))]);
            set(plt2, 'ydata', [get(plt2, 'ydata') imag(embedding(ind+numel(embedding)/2))]);          
        end
        drawnow
        
    end

end