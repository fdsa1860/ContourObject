function [seg, shortSeg] = contour2segModelSwitch(contour, opt)

n = length(contour);
seg = struct('points',{}, 'vel',{}, 'loc',{},'reg',{},'order',{});
shortSeg = struct('points',{}, 'vel',{}, 'loc',{},'reg',{},'order',{});
for i = 1:n
%     [subSeg, shortSubSeg] = contour2segMS(contour(i).points, opt);
    [subSeg, shortSubSeg] = contour2segMS_greedy(contour(i).points, opt);
    seg = [seg subSeg];
    shortSeg = [shortSeg shortSubSeg];
end

end