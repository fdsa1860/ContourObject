function bestcontour = extendcontour(contour, W,F, Pi,x,y,pb,max_gap)
Ft = F';
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
    
    % Find all possible ways to extend it
    ind1 = find(Ft(:,contour(end))~=0 | F(:,contour(end))~=0);
    val1 = Ft(ind1,contour(end));
    Dmat1 = ipdm([x(contour(end),1), y(contour(end),1)],[x(ind1,1) y(ind1,1)]);
    ind2 = find(Ft(:,contour(1))~=0 | F(:,contour(1))~=0);
    val2 = F(ind2,contour(1));
    Dmat2 = ipdm([x(contour(1),1), y(contour(1),1)],[x(ind2,1) y(ind2,1)]);
    ind = [ind1; ind2];
    dir = [ones(size(ind1)); 2*ones(size(ind2))];
    Dmat = [Dmat1 Dmat2];
    [junk idx] = sort([val1; val2], 'descend');
    ind = ind(idx);
    Dmat = Dmat(idx);
    dir = dir(idx);
    [dists idx] = sort(Dmat, 'ascend');
    ind = ind(idx);
    dir = dir(idx);
    dir = dir(dists > 0 & dists < max_gap);
    ind = ind(dists > 0 & dists < max_gap);
    dir = dir(~ismember(ind, [contour contour+size(W,1)/2]));
    ind = ind(~ismember(ind, [contour contour+size(W,1)/2]));
    if isempty(ind)
        break;
    end
    
    bestscoreextended = -inf;
    bestcontourextended = [];
    extended = false;
    for i = 1:numel(ind)
        if dir(i)==1
            newcontour = [contour; ind(i)];
        else
            newcontour = [ind(i); contour];
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
%     
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

