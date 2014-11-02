function [splitedContour, contour] = splitContour(contour, opt)

splitedContour = [];
for i = 1:length(contour)
    dsca = {contour(i).dsca};
    cont = {contour(i).points};
    % segment with sliding window
    % if isempty(dsca) || isempty(cont), splitedContour=[]; return; end
    [dsca, points, loc,~,~,splitedContour] = slideWindowChopContour(dsca, cont, 2*opt.hankel_size);
    nSeg = length(dsca);
    seg(1:nSeg) = struct('points',[], 'dsca',[], 'loc',[0 0], 'label',0);
    for j = 1:nSeg
        seg(j).points = points{j};
        seg(j).dsca = dsca{j};
        seg(j).loc = loc(j, :);
    end
    contour(i).seg = seg;
    contour(i).seg_dsca = dsca;
    contour(i).seg_points = points;
    contour(i).locs = loc;
    seg = struct('points',[], 'dsca',[], 'loc',[], 'label',[]); 
end

end