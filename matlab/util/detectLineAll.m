function index_all = detectLineAll(dsca_all)
% Input:
% dsca_all: 1 by N cell, N is the number of images, each cell contains all
% the cumulative angle derivative
% Output:
% index_all: 1 by N cell, each cell contains binary index indicating
% whether the corresponding segment is a line or not

numImg = length(dsca_all);
index_all = cell(1, numImg);
for i = 1:numImg
    if verbose
        fprintf('Processing image %d ... \n', i);
    end
    index_all{i} = detectLineAll(dsca_all{i});
end

end