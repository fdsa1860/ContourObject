function x = find_continuous_local_max(F, Pi, x)

bestcost = real(x'*F*x)/real(x'*Pi*x);
ind = find(x~=0);

ctr = 0;
while ctr < numel(ind)^2;
    %Choose a random point
    randind = randi(numel(ind));
    randind = ind(randind);
    %Choose a random direction
    randang = rand()*2*pi;
    %Move the point
    xnew = x;
    xnew(randind) = (real(xnew(randind))+ 0.05*cos(randang)) +...
        1i * (imag(xnew(randind))+ 0.05*sin(randang));
    xnew(ind) = xnew(ind)./abs(xnew(ind));
    newcost = real(xnew'*F*xnew)/real(xnew'*Pi*xnew);
    if newcost > bestcost
        x = xnew;
        bestcost = newcost;
        ctr = 0;
    end      
    ctr = ctr+1;
    disp([bestcost ctr]);
end

