function img_all = img2contour_all(imgList, labels, opt)

if strcmp(opt.dataset, 'mytrain')
    margin = 16;
elseif strcmp(opt.dataset, 'mytest')
    margin = 3;
end

numImg = length(imgList);
img_all = cell(1, numImg);
for i = 1:numImg
    if opt.verbose, fprintf('Processing image %d ... \n', i); end
    try
        load(sprintf(opt.localDir, opt.dataset, i), 'img');
    catch
        I_raw = im2double(imread(imgList{i}));
        I = I_raw(margin+1:end-margin, margin+1:end-margin, :);
        contour = img2contour_fast(I);
        img = [];
        img.opt = opt;
        img.width = size(I, 2);
        img.height = size(I, 1);
        img.contour = contour;
        img = imgAddSeg(img);
        img = imgAddHH(img);
        img = imgAddSigma(img);
        if ~isempty(img.seg)
            img.locs = cat(1,img.seg.loc);
        end
        img.label = labels(i);
        save(sprintf(opt.localDir, opt.dataset, i), 'img');
    end
    img_all{i} = img;
end

if opt.verbose
    fprintf('Process finished!\n');
end


end