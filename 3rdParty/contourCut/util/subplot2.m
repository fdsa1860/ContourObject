function h = subplot2(p,q,i,j,border);

if nargin < 5
    border = 0.1;
end
border_p = 1/p*border;
border_q = 1/q*border;
h = subplot('Position',[(j-1)/q+border_q/2, (p-i)/p+border_p/2, 1/q-border_q , 1/p-border_p]);
