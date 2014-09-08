function T = findTranslation(seg,order)

[N,D] = size(seg);
T = zeros(1,D);
s = sym('s');
for i = 1:D
    x = seg(:,i);
%     H = hankel(x(1:floor(N/2)),x(floor(N/2):end));
    H = hankel_mo(x',[order,27-order]);
    tic
    d = det((H+s)*(H+s).');
    toc
    coef = sym2poly(vpa(d));
    r = roots(coef);
    if(isempty(r))
        T(i) = 0;
        continue;
    end
    assert(length(r)==2);
    T(i) = real(r(1));
end

end