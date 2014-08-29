function bestcontour = trimcontour(contour, W,F, Pi,x,y,pb)
Wt = W';
MAXAHEAD = 50;

contour2 = contour;
contour2(contour > size(W,1)/2) = contour2(contour > size(W,1)/2) - size(W,1)/2;
contour2(contour <= size(W,1)/2) = contour2(contour <= size(W,1)/2) + size(W,1)/2;
contour2 = [contour contour2];
emb = zeros(size(W,1),1);
for j = 1:numel(contour2)
    emb(contour2(j)) = exp(1i*2*pi/(numel(contour2))*j);
end


% Get contour score

score = real(real(emb'*F*exp(-1i*2*pi/numel(contour2))*emb)/(emb'*Pi*emb));
ahead = 0;
bestcontour = contour;
bestscore = score;

bestahead = 0;
while 1
    
    if isempty(contour)
        break;
    end
    
    bestscoreextended = -inf;
    bestcontourextended = [];
    extended = false;
    for i = 1:2
        if i==1
            newcontour = contour(1:end-1);
        else
            newcontour = contour(2:end);
        end
        % Get contour score
        newcontour2 = newcontour;
        newcontour2(newcontour > size(W,1)/2) = newcontour2(newcontour > size(W,1)/2) - size(W,1)/2;
        newcontour2(newcontour <= size(W,1)/2) = newcontour2(newcontour <= size(W,1)/2) + size(W,1)/2;
        newcontour2 = [newcontour fliplr(newcontour2)];
        emb = zeros(size(W,1),1);
        for j = 1:numel(newcontour2)
            emb(newcontour2(j)) = exp(1i*2*pi/(numel(newcontour2))*j);
        end
        newscore = real(real(emb'*F*exp(-1i*2*pi/numel(newcontour2))*emb)/(emb'*Pi*emb));
        
        if newscore > bestscore
            bestscore = newscore;
            bestcontour = newcontour;
            score = newscore;
            contour = newcontour;
            extended = true;
            bestahead = max(ahead,bestahead);
            ahead = 0;
            break;
        end
        if newscore > bestscoreextended
            bestscoreextended = newscore;
            bestcontourextended = newcontour;
        end
    end
    
    if ~extended
        contour = bestcontourextended;
        score = bestscoreextended;
        ahead = ahead+1;
    end
    if ahead > MAXAHEAD
        break;
    end
    
%     clf;
%     imagesc(pb);
%     colormap(gray)
%     hold on;
%     xcont = x(bestcontour,1);
%     ycont = y(bestcontour,1);
%     plot(xcont,ycont, '.-b');
%     title(bestscore);
%     drawnow
end


