function [sorder, X] = orderEst(X, isLine)
% Input:
% seg: segments of contours
% line_id: the index of straight lines
% Output:
% sorder: segments order
% seg: cleaned segments

numSeg = length(X);
sorder = zeros(1, numSeg);
od = zeros(1, numSeg);
for i = 1:numSeg
    
    % sorder(i) = getOrder(sH{i}, 0.95);
    
    % denoise feature
    [X_tmp,~,~,od(i)] = fast_incremental_hstln_mo(X{i}',0.01);
    X{i} = X_tmp';
    sorder(i) = od(i);
    
end

% set the order of lines to zero
sorder(isLine) = 0;

end