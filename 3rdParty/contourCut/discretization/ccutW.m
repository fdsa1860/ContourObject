function [eig_vec lambda, F, Pi, P] = ccutW(W, delta_min, delta_max, delta_step, num_eigs, alg)
% Computes the local maxima of the relaxed contour cut function

% Compute P
P = diag(1./sum(abs(W),2))*W;
P(isnan(P)) = 0;
% Add small "random" transisions to make sure it has a unique stationary
% distribution
alpha = 0.99;
P = alpha*P + (1-alpha)/size(P,1) * ones(size(P));
% Get the stationary distribution
opts.disp = 0;
opts.isreal = false;
[s D] = eigs(sparse(P'), 1, 'lr', opts);
s = s*sign(s(1));
% Computer F matrix
F = diag(s)*P;
Pi = diag(s);
Pi_inv = diag(1./s);

if strcmp(alg, 'exact')
    % % % % % % % % % % % % % % % % %
    % Solve Hermitian eigenvalue problem
    % % % % % % % % % % % % % % % % %
    deltas = delta_min:delta_step:delta_max;
    xs = nan([numel(deltas)  num_eigs size(P,1)]);
    vals = nan([numel(deltas) num_eigs]);

    str_len = 0;
    for ii = 1:numel(deltas)
        delta = deltas(ii);
        H = (P*exp(-1i*delta) + Pi_inv*P'*Pi*exp(1i*delta))/2;
        [V D] = eigs(H, num_eigs, 'lr', opts);
        D = real(D); % Should be real, but make it in case of numerical error
        D = diag(D);
        [junk ind] = sort(D, 'descend');
        D = D(ind);
        V = V(:,ind);
        V(:,D<0)=0;
        D(D<0) = 0;
        % Record data
        for i = 1:size(D,1)
            x = V(:,i);
            xs(ii, i, :) = x;
            vals(ii,i) = D(i);
        end
        
        backspace_string = repmat('\b', [1 str_len]);
        str = sprintf('%d/%d, %f%%%%', ii, numel(deltas), 100*ii/numel(deltas));
        str_len = length(sprintf(str));
        fprintf(backspace_string);
        fprintf(str);
    end
    fprintf('\n');
    
    % % % % % % % % % % % % % % % % %
    % Find the local maxima
    % % % % % % % % % % % % % % % % %

    allxs = [];
    allvals = [];
    warning off;
    for i = 1:size(vals,2) % Loop over 1st eigenvalue, 2nd, etc.

        [pks locs] = findpeaks(abs(vals(:,i)));
        if ~isempty(locs)
            % Keep first local maximum for this eigenvector
            allvals = [allvals vals(locs(1),i)']; 
            allxs = [allxs reshape( squeeze(xs(locs(1),i,:))', [size(xs,3) numel(locs(1))]) ];
        end 
    end
    warning on;
    
elseif strcmp(alg, 'approx-right')
    [allxs allvals] = eigs(P, num_eigs, 'lr', opts);
    allvals = diag(allvals);
    
elseif strcmp(alg, 'approx-left')
    [allxs allvals] = eigs(P', num_eigs, 'lr', opts);
    allvals = diag(allvals);
    allxs = Pi_inv*allxs;
    
elseif strcmp(alg, 'approx-left-nonorm')
    [allxs allvals] = eigs(P', num_eigs, 'lr', opts);
    allvals = diag(allvals);
end

% % % % % % % % % % % % % % % % %
eig_vec = allxs;
lambda = allvals;
