function [Y] = pooling(X_all, sampleNum, poolMaxSize)

if nargin < 2
    sampleNum = 1000;
end
if nargin < 3
    poolMaxSize = 10000;
end

rng('default');
nX = length(X_all);
assert(nX > sampleNum);
ri = randi(nX, sampleNum, 1);
Y(1:poolMaxSize) = struct('dsca',[], 'H', [], 'HH',[], 'sigma',[]);
counter = 0;
for i = 1:sampleNum
    X = X_all{ri(i)};
    nd = length(X);
    counterEnd = counter + nd;
    if counterEnd > poolMaxSize,
        break;
    end
    Y(counter+1:counterEnd) = X;
    counter = counterEnd;
end
Y(counter+1:end) = [];

end