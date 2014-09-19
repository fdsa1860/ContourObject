function [Y, yOrder, yH, yHH] = pooling(X, xOrder, xH, xHH, sampleNum, poolMaxSize)

if nargin < 5
    sampleNum = 1000;
end
if nargin < 6
    poolMaxSize = 10000;
end


rng(0);
nX = length(X);
assert(nX > sampleNum);
ri = randi(nX, sampleNum, 1);
Y = cell(1, poolMaxSize);
yOrder = zeros(1, poolMaxSize);
yH = cell(1, poolMaxSize);
yHH = cell(1, poolMaxSize);
counter = 0;
for i = 1:sampleNum
    nd = length(X{ri(i)});
    counterEnd = counter + nd;
    if counterEnd > poolMaxSize,
        break;
    end
    Y(counter+1:counterEnd) = X{ri(i)};
    yOrder(counter+1:counterEnd) = xOrder{ri(i)};
    yH(counter+1:counterEnd) = xH{ri(i)};
    yHH(counter+1:counterEnd) = xHH{ri(i)};
    counter = counterEnd;
end
Y(counter+1:end) = [];
yOrder(counter+1:end) = [];
yH(counter+1:end) = [];
yHH(counter+1:end) = [];

end