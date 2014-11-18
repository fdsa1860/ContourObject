function seg_all = imgContour2Seg_all(img_all, opt)

segLength = opt.segLength;
numImg = length(img_all);
seg_all = cell(1, numImg);
for i = 1:numImg
    if opt.verbose, fprintf('Processing segments of image %d ... \n', i); end
    try
        load(sprintf(opt.segDir, opt.dataset, segLength, i), 'seg');
    catch
        img = img_all{i};
        % filter length
        contour = filterContourWithFixedLength(img.contour, segLength);
%         if isempty(contour), seg = []; continue; end
        % segment with sliding window
        seg = slideWindowContour2Seg(contour, segLength);
        seg = addHH(seg);
        seg = sigmaEst(seg);
        save(sprintf(opt.segDir, opt.dataset, segLength, i), 'seg');
    end
    seg_all{i} = seg;
end

if opt.verbose, fprintf('Segments Processing finished!\n'); end

end