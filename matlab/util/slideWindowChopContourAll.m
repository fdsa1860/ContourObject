function [X_new] = slideWindowChopContourAll(X, winSize)

numImg = length(X);
X_new = cell(1, numImg);
for i = 1:numImg
    if isempty(X{i})
        continue;
    end
    X_new{i} = slideWindowChopContour(X{i}, winSize);
end

end