% test mexHankel

x = randn(5, 100);
H1 = hankel_mo(x, [40 61]);
H2 = mexHankel(x, [40 61]);

d = H1-H2;

max(d(:))