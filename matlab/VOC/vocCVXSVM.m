tic

cvx_solver gurobi;
cvx_save_prefs;

cvx_begin
C = 0.1;
y = detector.gt';
x = double(detector.FD');
variables w(2304);
variables xi(length(y));
obj = w'*w + C * norm(xi);
y.*(x*w) >= 1 - xi;
xi >= 0;
minimize(obj);
cvx_end


toc