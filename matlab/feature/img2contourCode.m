function [contCode, img] = img2contourCode(img)

margin = 16;
I_raw = im2double(imread(img.imgFile));
I = I_raw(margin+1:end-margin, margin+1:end-margin, :);
opt = img.opt;

img.imgSize = [size(I,1) size(I,2)];

hankel_mode = opt.hankel_mode;
hankel_size = opt.hankel_size;
alpha = opt.alpha;
centers = img.centers;

contour = img2contour(I, opt.draw);
[splitedContour, contour] = splitContour(contour, opt);

img.cont = contour;

numCont = length(contour);
contCode = cell(1, numCont);
for i = 1:numCont
    curr = contour(i);
    len = length(curr.seg_dsca);
    contCode{i} = zeros(len, 1);
    contour(i).inds = zeros(len, 1);
    img.cont(i).inds = zeros(len, 1);
    isLine = dscaLineDetect(curr.seg_dsca);
    
    segLine = curr.seg_points(isLine);
    slope = slopeEst(segLine);
    step = pi / opt.nBins;
    index = ceil((slope + pi/2) / step);
    contCode{i}(isLine) = index;
        
    dscaNotLine = curr.seg_dsca(~isLine);
    if ~isempty(dscaNotLine)
        numSeg_notLine = length(dscaNotLine);
        seg(1:numSeg_notLine) = struct('dsca',[], 'H',[], 'HH',[]);
        for j = 1:numSeg_notLine
            if isempty(dscaNotLine{j}),seg(j)=[];continue; end
            seg(j).dsca = dscaNotLine{j};
            [seg(j).H, seg(j).HH] = buildHankel(seg(j).dsca, hankel_size, hankel_mode);
        end
        seg = sigmaEst(seg);
        D = dynamicDistanceSigmaCross(seg, centers, alpha);
        [~,ind] = min(D, [], 2);
        contCode{i}(~isLine) = opt.nBins + ind;
    end
    
    contour(i).inds = contCode{i};
    img.cont(i).inds = contCode{i};
    seg = struct('dsca',[], 'H',[], 'HH',[]);
end

end