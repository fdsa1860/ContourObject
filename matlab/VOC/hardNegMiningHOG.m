function detector = hardNegMiningHOG(detector)

feat = double(detector.FD);
gt = detector.gt;

nP = nnz(gt==1);
nN = nnz(gt==-1);
featP = feat(:, gt==1);
featN = feat(:, gt==-1);
gtP = gt(gt==1);
gtN = gt(gt==-1);
feat = [featN, featP];
gt = [gtN, gtP];

nN_MAX = 5000;
n_MAX = 20000;

% random negative
rng('default');
indN = randperm(nN, min(nN, nN_MAX));
indP = nN+1:nN+nP;
ind = [indN, indP];

tic
C = 0.01;
E = 1e-2;
while true
    X = feat(:, ind);
    y = gt(:, ind);
    numPos = nnz(gt==1);
    numNeg = nnz(gt==-1);
    posWeight = numNeg/numPos;
%     posWeight = 100;
    m = train(y',sparse(X),sprintf('-s 2 -c %f -e %f -B 1 -w1 %f -w-1 1 -q', C, E, posWeight),'col');
    [~, ~, conf] = predict(gt', sparse(feat), m, '-q', 'col');
    if exist('L','var'), L_pre = L; end
    L = 0.5 * m.w * m.w' + C * sum(max(0, 1 - y .* (m.w * [X; ones(1, length(y))])).^2);
%     m = svmtrain(y',sparse(X'),sprintf('-s 0 -t 0 -w1 %d -w-1 1',posWeight));
% %     [~, ~, conf] = svmpredict(gt', sparse(feat)', m, '-q');
%     w = m.sv_coef' * m.SVs;
%     conf = (w * feat - m.rho)';
%     L = 0.5 * (w * w') + sum(max(0, 1 - y .* (w * X + m.rho)).^2);
    L
    if exist('L_pre','var'), if L < L_pre, E = E/10; continue; end; end
    delta = 0;
    indEasy = find(gt.*conf'>1+delta);
%     indHard = find(gt.*conf'<1+delta);
    dec = gt.*conf';
    [dec_sorted, index] = sort(dec);
    indHard = index(dec_sorted<1+delta);
%     indHard = union(indHard, indP);
    ind = setdiff(ind, indEasy);
    indHardNew = setdiff(indHard, ind, 'stable');
    if isempty(indHardNew), break; end
%     if length(ind)<n_MAX, nNew=min(length(indHardNew), n_MAX-length(ind));
%     else n_MAX=2*n_MAX;nNew=min(length(indHardNew), n_MAX-length(ind));end
    ind =[ind, indHardNew];
%     ind = [ind, indHardNew(1:nNew)];
end
toc
detector.model = m;

end