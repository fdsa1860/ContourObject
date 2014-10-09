function [accuracyMat, libsvmModel] = libsvmClassify(feat1, labels1, feat2, labels2)

fprintf('classifying ...\n');

addpath(genpath('../3rdParty/libsvm-3.18/matlab'));

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
            model = svmtrain(y_train',sparse(X_train'),sprintf('-t 0 -c %d',C(ci)));
            %             [predict_label, ~, prob_estimates] = predict(y_validate2', sparse(X2_validate'), model);
            %             accuracy(i) = nnz(predict_label==y_validate2')/length(y_validate2);
            [predict_label, ~, prob_estimates] = svmpredict(y_test', sparse(X_test'), model);
            accuracy = nnz(predict_label==y_test')/length(y_test);
            libsvmModel = model;
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
    numTrain = length(y_train);
    numTest = length(y_test);
    
    Cind = 1;
    Gind = 1;
    C = 2.^Cind;
    G = 10.^Gind;
    %     C = 0.1;
    accuracyMat = zeros(length(G),length(C));
    libsvmModel = cell(length(G),length(C));
    for gi = 1:length(G)
        for ci = 1:length(C)
%             K_train = [ (1:numTrain)' , chi2Kernel(X_train', X_train', G(gi)) ];
%             K_test = [ (1:numTest)'  , chi2Kernel(X_test', X_test', G(gi)) ];
%             model = svmtrain(y_train',K_train,sprintf('-t 4 -c %d', C(ci)));
%             [predict_label, ~, prob_estimates] = svmpredict(y_test', K_test, model);
            model = svmtrain(y_train',sparse(X_train'),sprintf('-h 0 -s 0 -t 0 -c %d',C(ci)));
            [predict_label, ~, prob_estimates] = svmpredict(y_test', sparse(X_test'), model);
%             [predict_label, ~, prob_estimates] = predict(y_validate2', sparse(X2_validate'), model);
%             accuracy(i) = nnz(predict_label==y_validate2')/length(y_validate2);
            
            accuracy = nnz(predict_label==y_test')/length(y_test);
            libsvmModel{gi, ci} = model;
            fprintf('G = %f, C = %f, accuracy is %f\n', G(gi), C(ci), accuracy);
            accuracyMat(gi, ci) = accuracy;
        end
    end
else
    fprintf('the number of arguments should be either 2 or 4\n');
end

rmpath(genpath('../3rdParty/libsvm-3.18/matlab'));

end

function D = chi2Kernel(X,Y,gamma)
D = zeros(size(X,1),size(Y,1));
for i=1:size(Y,1)
    d = bsxfun(@minus, X, Y(i,:));
    s = bsxfun(@plus, X, Y(i,:));
    D(:,i) = sum(d.^2 ./ (s/2+eps), 2);
end
D = exp(-gamma * D);
end