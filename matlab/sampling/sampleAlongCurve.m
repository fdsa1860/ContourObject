function output = sampleAlongCurve(data, mode, fixed)

output = cell(length(data),1);
for i = 1:length(data)
    output{i} = resample(data{i}, mode, fixed);
%     output{i} = intpSample(data{i}, mode, fixed);
end

end