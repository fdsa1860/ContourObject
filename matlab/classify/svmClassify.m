function svmClassify(feat, labels)

addpath(genpath('../3rdParty/liblinear-1.94/matlab'));

% ind = randperm(200);
% feat_perm = feat(:,ind);
% labels_perm = labels(ind);
% X_train = feat_perm(:,1:150);
% X_test = feat_perm(:,151:200);
% y_train = labels_perm(1:150);
% y_test = labels_perm(151:200);
% feat = feat(:,1:4832);
% labels = labels(1:4832);

% load ../expData/feat_mytrain_hOrder_a0_20140925;
% X_train = feat;
% y_train = labels;
% X_train = feat(:,1:4832);
% y_train = labels(1:4832);
% load ../expData/feat_mytest_hOrder_a0_20140925;
% X_test = feat;
% y_test = labels;
    
K = 5;
ind = crossvalind('Kfold',length(labels),K);
accuracyCross = zeros(1, K);
for k = 1:K
    X_train = feat(:,ind~=k);
    X_test = feat(:,ind==k);
    y_train = labels(ind~=k);
    y_test = labels(ind==k);
    
    % Cind = -1:10;
    % C = 2.^Cind;
    C = 0.1;
    accuracyMat = zeros(1,length(C));
    for ci = 1:length(C)
        model = train(y_train',sparse(X_train'),sprintf('-s 2 -c %d',C(ci)));
        %         [predict_label, ~, prob_estimates] = predict(y_validate2', sparse(X2_validate'), model);
        %         accuracy(i) = nnz(predict_label==y_validate2')/length(y_validate2);
        [predict_label, ~, prob_estimates] = predict(y_test', sparse(X_test'), model);
        accuracy = nnz(predict_label==y_test')/length(y_test);
        svmModel = model;
        fprintf('\naccuracy is %f\n',mean(accuracy));
        accuracyMat(ci) = mean(accuracy);
    end
    accuracyCross(k) = accuracy;
end
rmpath(genpath('../3rdParty/liblinear-1.94/matlab'));

end