function seg = contour2segModelSwitch(contour, opt)

n = length(contour);
seg = struct('points',{}, 'vel',{}, 'loc',{});
for i = 1:n
    subseg = contour2segMS(contour(i).points, opt);
    seg = [seg subseg];
end

end