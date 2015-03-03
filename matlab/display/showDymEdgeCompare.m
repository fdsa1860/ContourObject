function accMat = showDymEdgeCompare(dym)

% for i = 1:length(dym)
%     dym{i}.dymBoundaries = double(dym{i}.dymBoundaries~=0);
% end

n = length(dym);
accMat = zeros(n,n);
for i = 1:n
    for j = 1:n
        accMat(i,j) = dymEdgeCompare(dym{i}.dymBoundaries, dym{j}.dymBoundaries);
    end
end

imagesc(accMat);

end