function svmClassify(feat1, labels1, feat2, labels2)

fprintf('classifying ...\n');

addpath(genpath('../3rdParty/liblinear-1.94/matlab'));

if nargin == 2
    
    rng('default')
    K = 5;
    ind = crossvalind('Kfold',length(labels1),K);
    accuracyCross = zeros(1, K);
    for k = 1:K
        X_train = feat1(:,ind~=k);
        X_test = feat1(:,ind==k);
        y_train = labels1(ind~=k);
        y_test = labels1(ind==k);
        % Cind = -1:10;
        % C = 2.^Cind;
        C = 0.1;
        accuracyMat = zeros(1,length(C));
        for ci = 1:length(C)
            model = train(y_train',sparse(X_train'),sprintf('-s 2 -c %d',C(ci)));
%             [predict_label, ~, prob_estimates] = predict(y_validate2', sparse(X2_validate'), model);
%             accuracy(i) = nnz(predict_label==y_validate2')/length(y_validate2);
            [predict_label, ~, prob_estimates] = predict(y_test', sparse(X_test'), model);
            accuracy = nnz(predict_label==y_test')/length(y_test);
            svmModel = model;
            fprintf('\naccuracy is %f\n',mean(accuracy));
            accuracyMat(ci) = mean(accuracy);
        end
        accuracyCross(k) = accuracy;
    end
    
elseif nargin == 4
    X_train = feat1;
    X_test = feat2;
    y_train = labels1;
    y_test = labels2;
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
else
    fprintf('the number of arguments should be either 2 or 4\n');
end

rmpath(genpath('../3rdParty/liblinear-1.94/matlab'));

end