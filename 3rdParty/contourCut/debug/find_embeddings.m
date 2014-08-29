% Click on the edges (black boxes) on the image to trace out a contour.
% Then, press a key and the contour is shown in the embeddings.  The
% embeddings can be cycled through using the arrow keys.
%
% To save the emebdding, set savefile to the name of the file to save to.
% To load an embedding, set loadfile to the name of the file to load from.
% Both savefile and loadfile may be set to [] (in order to use savefile but
% skip the loadfile parameter, for example).
function find_embeddings(img, eig_vec, lambda, x, y, loadfile, savefile)

% First, trace out a contour
x1 = [];
y1 = [];
x2 = [];
y2 = [];
xp = [];
yp = [];

curreig = 1;
fig = figure;
ah = axes();
imagesc(img);
hold on;
sct = scatter(x(:,1), y(:,1),'rs');
set(sct, 'buttondownfcn', @func);
set(fig, 'keypressfcn', @func2);
plt3 =  plot(0,0, '.-g');
if exist('loadfile') && ~isempty(loadfile)
    load(loadfile);
    x1 = []; y1 = [];
    x2 = []; y2 = [];
    for i = 1:numel(xp)
        D = ipdm([xp(i) yp(i)], [x(:,1) y(:,1)]);
        [junk ind] = min(D);
        x1 = [x1; real(eig_vec(ind,:))];
        y1 = [y1; imag(eig_vec(ind,:))];
        x2 = [x2; real(eig_vec(ind+numel(eig_vec(:,1))/2,:))];
        y2 = [y2; imag(eig_vec(ind+numel(eig_vec(:,1))/2,:))];
            
    end
    set(plt3, 'xdata', xp);
    set(plt3, 'ydata', yp);
end

firsttime = true;

    function func(src,evnt)
        cp = get(ah,'CurrentPoint');
        D = ipdm(cp(1,1:2), [x(:,1) y(:,1)]);
        [junk ind] = min(D);
        
        if firsttime
            xp = x(ind,1);
            yp = y(ind,1);
            x1 = real(eig_vec(ind,:));
            y1 = imag(eig_vec(ind,:));
            x2 = real(eig_vec(ind+numel(eig_vec(:,1))/2,:));
            y2 = imag(eig_vec(ind+numel(eig_vec(:,1))/2,:));
            firsttime = false;
        else
            xp = [xp x(ind,1)];
            yp = [yp y(ind,1)];
            x1 = [x1; real(eig_vec(ind,:))];
            y1 = [y1; imag(eig_vec(ind,:))];
            x2 = [x2; real(eig_vec(ind+numel(eig_vec(:,1))/2,:))];
            y2 = [y2; imag(eig_vec(ind+numel(eig_vec(:,1))/2,:))];
        end
        set(plt3, 'xdata', xp);
        set(plt3, 'ydata', yp);
        drawnow
        if exist('savefile') && ~isempty(savefile)
            save(savefile, 'x1', 'y1', 'x2', 'y2', 'xp', 'yp');
        end
        
    end

    function func2(src,evnt)
        if strcmp(evnt.Key, 'rightarrow')
            curreig = curreig+1;
            if curreig > size(eig_vec,2)
                curreig = 1;
            end
        elseif strcmp(evnt.Key, 'leftarrow')
            curreig = curreig-1;
            if curreig < 1
                curreig = size(eig_vec,2);
            end
        end
        clf(fig);
        hold on;
        scatter(real(eig_vec(:,curreig)), imag(eig_vec(:,curreig)), '.b');
        plot(x1(:,curreig), y1(:,curreig), '.-r');
        plot(x2(:,curreig), y2(:,curreig), '.-g');
        title(sprintf('Eigenvector %d/%d, Eigenvalue %f', curreig, size(eig_vec,2), lambda(curreig)));
        axis equal;
    end

end