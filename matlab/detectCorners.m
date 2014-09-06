% Detect corners on contours extracted from images
% by finding local extremum in the derivative of cumulative angles

% Created by Xiao Zhang
% Modified by Xikang Zhang, on Sep 6 2014,
% add parameter MAX_FEATURE_LENGTH, set it 10 rather than original 40
% add parameter EFFECTIVE_LENGTH, set it 2 rather than original 30

function corners_index = detectCorners(feature, threshold)

MAX_FEATURE_LENGTH = 10;
EFFECTIVE_LENGTH = 2;

n = numel(feature);
local_extre = cell(1, n);
corners_index = cell(1, n);

for i = 1:n
    feature_length = numel(feature{i});
    if feature_length <= MAX_FEATURE_LENGTH
        continue;
    end
    
    local_max = find(diff(sign(diff([0; feature{i}(:); 0]))) < 0);
    local_max = local_max(local_max > EFFECTIVE_LENGTH & local_max < numel(feature{i})-EFFECTIVE_LENGTH);
    local_max = local_max(feature{i}(local_max) > threshold);
    
    local_min = find(diff(sign(diff([0; feature{i}(:); 0]))) > 0);
    local_min = local_min(local_min > EFFECTIVE_LENGTH & local_min < numel(feature{i})-EFFECTIVE_LENGTH);
    local_min = local_min(feature{i}(local_min) < -threshold);
    
    local_extre{i} = union(local_max, local_min, 'sorted');  
    corners_index{i} = local_extre{i} + 1;
end

% display the local extremum 
% hFig = figure;
% set(hFig, 'Position', [200 100 1000 700]);
% for i = 1:9
%     subplot(3, 3, i), plot(feature{i});
%     hold on;
%     plot(corners_index{i}, feature{i}(local_extre{i}), 'r*');
%     title(num2str(i), 'FontSize', 13);
% end

end