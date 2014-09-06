% Extract different features from curves
% Output:
%    dxy: the derivative of position (x, y) ----- velocity
%    cA: the cumulative angle
%    dA: the derivative of the cumulative angle


function [dxy, cA, dA] = extractFeature(curve)

dxy = curve(2:end, :) - curve(1:end-1, :);
dxy = dxy / sum(sqrt(sum(dxy.^2, 2)), 1);

[F, G, A] = cumulativeAngle(curve);

cA = G;
dA = cA(2:end) - cA(1:end-1);

cA(abs(cA) < 0.00001) = 0.00001;
dA(abs(dA) < 0.00001) = 0.00001;
dA = 10 .* dA / norm(dA, 2);

end
