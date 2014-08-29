function theta2 = interp_circ(max_i, pb, norient);
% theta2 = interp_circ(max_i, pb, norient);

% % Compute maximum in [-1, 1]
% max_x = zeros(size(max_i, 1), 1);
% a = pb(:, 1);
% b = pb(:, 2);
% c = pb(:, 3);
% idx = find(b*2-a-c > eps);
% max_x(idx) = (c(idx)-a(idx)) ./ (2*b(idx)-a(idx)-c(idx)) /2;
max_x = max_parab(pb);

theta2 = (max_x+max_i-1)*pi/norient;
