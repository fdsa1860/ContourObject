% midsize test
% Xikang Zhang, 06/16/2014

clc;clear;close all;
addpath(genpath('../3rdParty'));
addpath(genpath('../matlab'));

%% generate middle size data
genMidSizeData;

%% sample data along the curve
% data = sampleAlongCurve(data,1,1);

%% display data
figure(1);
axis([0 600 0 600])
set(gca,'YDir','Reverse');
for i = 1:length(data)
    hold on; plot(data{i}(:,1),data{i}(:,2),'*'); hold off;
end

%% get velocity
seg = data;
seg2 = cell(size(seg));
% h = [-1 0 0 0 1]';
h = [-1 0 1]';
for si=1:length(seg)
seg2{si} = conv2(seg{si},h,'valid');
end

%% match curve
selInd = 45;
x1 = seg2{selInd};
y1 = zeros(length(seg2),1);
y2 = zeros(length(seg2),1);
y3 = zeros(length(seg2),1);
y4 = zeros(length(seg2),1);
for si = 1:length(seg2)
% for si = 4
% if si==8, keyboard; end
x2 = seg2{si};
% y1(si) = hankeletAngle(x1,x2,0.99);
y1(si) = hankeletAngle(x1,x2);
y2(si) = myHankeletAngle2(x1,x2);
y3(si) = mySubspaceAngle(x1,x2,0.99);
y4(si) = mySubspaceAngle_vel(x1,x2,0.99);

end

figure(2);

subplot(121);

plot(seg{selInd}(:,1),seg{selInd}(:,2),'go');
for si = 1:length(seg)
    hold on;
    plot(seg{si}(:,1),seg{si}(:,2));
    set(gca,'YDir','Reverse');
    hold off;
end

ind = find(y1<1e-8);
for i = 1:length(ind)
    x2 = seg{ind(i)};
    hold on;plot(x2(:,1),x2(:,2),'r.');hold off;
    set(gca,'YDir','Reverse');
end

subplot(122);
plot(y1,'*');

%%
figure(3);
subplot(221);
si = 1;
plot(seg2{si}(:,1),'b.');hold on;plot(seg2{si}(:,2),'g.');hold off;legend dx dy;title('line');
subplot(222);
si = 21;
plot(seg2{si}(:,1),'b.');hold on;plot(seg2{si}(:,2),'g.');hold off;legend dx dy;title('circle');
subplot(223);
si = 37;
plot(seg2{si}(:,1),'b.');hold on;plot(seg2{si}(:,2),'g.');hold off;legend dx dy;title('ellipse');
subplot(224);
si = 45;
plot(seg2{si}(:,1),'b.');hold on;plot(seg2{si}(:,2),'g.');hold off;legend dx dy;title('sin');

figure(4);
subplot(221);
si = 2;
plot(seg2{si}(:,1),'b.');hold on;plot(seg2{si}(:,2),'g.');hold off;legend dx dy;title('line');
subplot(222);
si = 22;
plot(seg2{si}(:,1),'b.');hold on;plot(seg2{si}(:,2),'g.');hold off;legend dx dy;title('circle');
subplot(223);
si = 38;
plot(seg2{si}(:,1),'b.');hold on;plot(seg2{si}(:,2),'g.');hold off;legend dx dy;title('ellipse');
subplot(224);
si = 46;
plot(seg2{si}(:,1),'b.');hold on;plot(seg2{si}(:,2),'g.');hold off;legend dx dy;title('sin');

%% cluster
nc = 12;
figure(5);
% labelColor = 'bgrmcyk';
labelColor = jet(nc);
% [label,X_center] = kmeansContour(seg2,3);
[label,X_center,cntrInd,W] = nCutContour(seg2,nc);
% for si = 1:length(seg)
%     hold on;plot(seg{si}(:,1),seg{si}(:,2));hold off;
% end
for si = 1:length(seg)
    hold on;plot(seg{si}(:,1),seg{si}(:,2),'Color',labelColor(label(si),:));hold off;
    set(gca,'YDir','Reverse');
end
for ci = 1:length(cntrInd)
    hold on;plot(seg{cntrInd(ci)}(:,1),seg{cntrInd(ci)}(:,2),'o','Color',labelColor(ci,:));hold off;
    set(gca,'YDir','Reverse');
end

