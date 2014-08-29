function [ind,xi,yi]=get_samples(x,y,nsamp)
% [xi,yi]=get_samples(x,y,nsamp);
%
% uses Jitendra's sampling method

ind = 1:length(x);

N=length(x);
k=3;
Nstart=min(k*nsamp,N);

ind0=randperm(N);
ind0=ind0(1:Nstart);

ind = ind(ind0);
xi=x(ind0);
yi=y(ind0);
xi=xi(:);
yi=yi(:);
ind = ind(:);

d2=ipdm([xi yi],[xi yi]);
d2=d2+diag(Inf*ones(Nstart,1));

s=1;
while s
   % find closest pair
   [a,b]=min(d2);
   [c,d]=min(a);
   I=b(d);
   J=d;
   % remove one of the points
   xi(J)=[];
   yi(J)=[];
   ind(J) = [];
   d2(:,J)=[];
   d2(J,:)=[];
   if size(d2,1)==nsamp
      s=0;
   end
end

      