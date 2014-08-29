function ori = comp_contour_ori2(px, py, nb_nei);

if (nargin < 3)
    nb_nei = 4;
end

if (length(px) <= nb_nei)
    error('contour too short?');
end
px = px(:);
py = py(:);
n = length(px);
% % Endpts not right...
% px2 = [px(nb_nei:-1:1); px; px(n-1:-1:n-nb_nei)];
% py2 = [py(nb_nei:-1:1); py; py(n-1:-1:n-nb_nei)];

px2 = [repmat(px(1), [nb_nei, 1]); px; repmat(px(end), [nb_nei, 1])];
py2 = [repmat(py(1), [nb_nei, 1]); py; repmat(py(end), [nb_nei, 1])];

dx = zeros(n, 1);
dy = zeros(n, 1);
for ii = 1:nb_nei
    dx = dx + px2((nb_nei+1+ii):(n+nb_nei+ii)) - px2((nb_nei+1-ii):(n+nb_nei-ii));
    dy = dy + py2((nb_nei+1+ii):(n+nb_nei+ii)) - py2((nb_nei+1-ii):(n+nb_nei-ii));
end

ori = atan2(dy, dx);
