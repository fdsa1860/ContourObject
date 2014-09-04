% Compute the angular information of the input curve
% Input: 
%    curve: the position (x, y) of the curve
% Output:
%    A: the tangential angle 
%    G: the cumulative angle 
%    F: the normalized cumulative angle 

function [F, G, A] = cumulativeAngle(curve)

x = curve(:, 1);
y = curve(:, 2);
m = size(curve, 1);   % number of points

% compute the length of curve
% since we use dA = A(i+1) - A(i-1), the number of points in the output is m - 2.
m = m - 2;
S = zeros(m, 1);
for i = 2:m
    S(i) = S(i-1) + sqrt( (x(i+1)-x(i))^2 + (y(i+1)-y(i))^2 );
end
L = S(end);

A = zeros(m, 1);
for i = 1:m
    dx = x(i+2) - x(i);
    dy = y(i+2) - y(i);
    
    if(dx == 0) 
        dx = .00001; 
    end
    
    % map the vaule of angle into [0, 2*pi]
    if dx > 0 && dy >= 0
        A(i) = atan(dy/dx);
    elseif dx > 0 && dy < 0
        A(i) = atan(dy/dx) + 2*pi;
    else
        A(i) = atan(dy/dx) + pi;
    end      
end

% calculate the cumulative angle
G = zeros(m, 1);
for i = 2:m
    if (A(i) - A(i-1)) < -pi
        G(i) = G(i-1) - (A(i) - A(i-1) + 2*pi); 
    elseif (A(i) - A(i-1)) > pi
        G(i) = G(i-1) - (A(i) - A(i-1) - 2*pi);  
    else
        G(i) = G(i-1) - (A(i) - A(i-1)); 
    end 
end

% the normalized cumulative angle
t = (2*pi*S) / L;    % the normalized parameter
F = G + t;

% display the cumulative angle
% figure, subplot(221), plot(x, y);   
% MIN = min(curve);
% MAX = max(curve);
% axis([MIN(1)-5, MAX(1)+5, MIN(2)-5, MAX(2)+5]);
% axis square;                    
% title('Curve');
% 
% subplot(222), plot(S, A);
% axis([0, S(m), -1, 2*pi+1]);     
% title('Angular Function');
% 
% subplot(2, 2, 3), plot(S, G);                 
% %axis([0, S(m), -2*pi-1, 1]);   
% title('Cumulative');
% 
% subplot(2, 2, 4), plot(t, F);                  
% %axis([0, 2*pi, -pi, pi]);
% title('Normalized');

end