function output = sampleAlongCurve(data, mode, fixed)

output(1:length(data)) = struct('points',[]);
% output = cell(length(data),1);
for i = 1:length(data)
    output(i).points = resample(data{i}, mode, fixed);
%     output{i} = resample(data{i}, mode, fixed);
%     output{i} = intpSample(data{i}, mode, fixed);
end

end