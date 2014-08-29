% try countour data with hankelets

clear;clc;close all;

filePath = '../expData/contourData_zhangxiao';
% fileName = 'contour_g2.mat';
fileName = 'synthetic_contour.mat';
% fileName = 'contour2.mat';
% fileName = 'car1_filtered.mat';
data = importdata(fullfile(filePath,fileName));

ind1 = 1;
segLen = 46;
figure(1);
for di = 1:length(data)
    hold on;
    plot(data{di}(:,1),data{di}(:,2));
    set(gca,'YDir','Reverse');
    hold off;
end

% % erase short contours
% minLen = 5*8;
% idx = true(size(data,1),1);
% for di = 1:length(data)
%     if size(data{di},1) < minLen
%         idx(di) = false;
%     end
% end
% seg = data(idx);

% split curves into segments
% seg = splitContour(data,segLen);
% addpath('../3rdParty/hstln');
% seg = splitContour3(data);
seg = data;

% %% rank minimization denoise
% tic
% seg2 = cell(size(seg));
% for si = 1:length(seg)
% % for si = 39
%     x = seg{si};
%     xm = mean(x);
%     x = bsxfun(@minus, x, xm);
%     [m,n] = size(x);
%     H = hankel_mo(seg{si}');
%     cvx_begin
%     variable x_hat(m,n)
%     H_hat = hankel_mo(x_hat');
%     norm(x_hat - x,inf) <= 1;
%     minimize(norm_nuc(H_hat));
%     cvx_end
%     seg2{si} = bsxfun(@plus, x_hat, xm);
% end
% toc
%%

addpath('../3rdParty/hstln');
seg2 = cell(size(seg));
eta_thr = 0.6;
h = [-1 0 0 0 1]';
tic
for si=1:length(seg)
%     seg_v = diff(seg{si}(1:4:end,:));
    seg_v = conv2(seg{si},h,'valid');
    [seg_v2,~,~,R] = fast_incremental_hstln_mo(seg_v',eta_thr);
    R
    seg2{si} = seg_v2';
%     plot(seg_tmp(:,1),seg_tmp(:,2),'b-*');hold on;
%     plot(seg2{si}(:,1),seg2{si}(:,2),'r-*');hold off;
    35;
end
toc




% %% HSTLN
% tic
% addpath('../3rdParty/hstln');
% eta_thr = 0.05;
% eta_diff_thr = 0.03;
% seg2 = cell(size(seg));
% for si = 1:length(seg)
%     x = seg{si};
%     xm = mean(x);
%     x = bsxfun(@minus, x, xm);
%     x_hat = x';
%     order = 0;
%     norm_eta = inf;
%     norm_eta_pre = norm_eta;
%     norm_eta_diff = inf;
%     while norm_eta > eta_thr || norm_eta_diff > eta_diff_thr
%         
%         order = order + 1;
%         
%         x_hat_pre = x_hat;
%         norm_eta_diff_pre = norm_eta_diff;
%         
%         [x_hat,eta] = hstln_mo(x',order);
%         norm_eta = norm(eta)/numel(eta);
%         norm_eta_diff = norm_eta_pre - norm_eta;
%         norm_eta_pre = norm_eta;
%         
%     end
%     
%     if norm_eta_diff_pre > eta_diff_thr
%         x_hat = x_hat_pre;
%         order = order - 1;
%     end
%     
%     x_hat = x_hat';
%     x_hat = bsxfun(@minus, x_hat, mean(x_hat));
%     H = hankel_mo(x_hat');
%     O = orth(H);
%     [order size(O,2)]
%     seg2{si} = bsxfun(@plus, x_hat, xm);
% end
% rmpath('../3rdParty/hstln');
% toc


%% alm denoise
% addpath('../3rdParty/l2-fast-alm');
% lambda = 10;
% seg2 = cell(size(seg));
% for si = 1:length(seg)
%     u = seg{si};
%     u = u ./ repmat(max(u),[size(u,1),1]) - 0.5;
%     [m,n] = size(u);
%     P = eye(m);
%     x_hat = l2_fastalm_mo(u(:,1)',lambda,P);
%     y_hat = l2_fastalm_mo(u(:,2)',lambda,P);
%     u_hat = [x_hat' y_hat'];
%     seg2{si} = u_hat;
% end
% rmpath('../3rdParty/l2-fast-alm');

% %% alm cvx
% lambda = 100;
% seg2 = cell(size(seg));
% for si = 19
%     u = seg{si}(:,2);
%     u = u ./ repmat(max(u),[size(u,1),1]);
%     u = u - repmat(mean(u),[size(u,1),1]);
% %     [m,n] = size(u);
% %     P = eye(m);
%     cvx_begin sdp
%     variable u_hat_cvx(size(u))
%     minimize norm_nuc(hankel_mo(u_hat_cvx)) + lambda/2 * pow_pos(norm(u_hat_cvx(:) - u(:),'fro'),2)
%     cvx_end
%     u_hat = u_hat_cvx;
% end

% seg2 = seg;

%% match curve
selInd = 1;
x1 = seg2{selInd};
y1 = zeros(length(seg2),1);
y2 = zeros(length(seg2),1);
y3 = zeros(length(seg2),1);
y4 = zeros(length(seg2),1);
for si = 1:length(seg2)
% for si = 4
x2 = seg2{si};
y1(si) = hankeletAngle(x1,x2,0.99);
y2(si) = myHankeletAngle(x1,x2,0.99);
y3(si) = mySubspaceAngle(x1,x2,0.99);
y4(si) = mySubspaceAngle_vel(x1,x2,0.99);

end


figure(1);
plot(seg{selInd}(:,1),seg{selInd}(:,2),'go');
for si = 1:length(seg)
% for si = 45
    hold on;
    plot(seg{si}(:,1),seg{si}(:,2));
    set(gca,'YDir','Reverse');
    hold off;
end

ind = find(y1<0.6);
for i = 1:length(ind)
% for si = 1:length(seg)
    x2 = seg{ind(i)};
%     x2 = seg2{36}';
    hold on;plot(x2(:,1),x2(:,2),'r.');hold off;
    set(gca,'YDir','Reverse');
end

figure(2);
plot(seg{selInd}(:,1),seg{selInd}(:,2),'go');
for si = 1:length(seg)
% for si = 45
    hold on;
    plot(seg{si}(:,1),seg{si}(:,2));
    set(gca,'YDir','Reverse');
    hold off;
end

ind = find(y2<0.8);
for i = 1:length(ind)
% for si = 1:length(seg)
    x2 = seg{ind(i)};
%     x2 = seg2{36}';
    hold on;plot(x2(:,1),x2(:,2),'r.');hold off;
    set(gca,'YDir','Reverse');
end

figure(3);
plot(seg{selInd}(:,1),seg{selInd}(:,2),'go');
for si = 1:length(seg)
% for si = 45
    hold on;
    plot(seg{si}(:,1),seg{si}(:,2));
    set(gca,'YDir','Reverse');
    hold off;
end

ind = find(y3 < 0.3);
for i = 1:length(ind)
% for si = 1:length(seg)
    x2 = seg{ind(i)};
%     x2 = seg2{36}';
    hold on;plot(x2(:,1),x2(:,2),'r.');hold off;
    set(gca,'YDir','Reverse');
end

figure(4);
plot(seg{selInd}(:,1),seg{selInd}(:,2),'go');
for si = 1:length(seg)
% for si = 45
    hold on;
    plot(seg{si}(:,1),seg{si}(:,2));
    set(gca,'YDir','Reverse');
    hold off;
end

ind = find(y4<1.5);
for i = 1:length(ind)
% for si = 1:length(seg)
    x2 = seg{ind(i)};
%     x2 = seg2{36}';
    hold on;plot(x2(:,1),x2(:,2),'r.');hold off;
    set(gca,'YDir','Reverse');
end

figure(5);
labelColor = 'bgrmcyk';
% [label,X_center] = kmeansContour(seg2,3);
[label,X_center,cntrInd,W] = nCutContour(seg2,6);
% for si = 1:length(seg)
%     hold on;plot(seg{si}(:,1),seg{si}(:,2));hold off;
% end
for si = 1:length(seg)
    hold on;plot(seg{si}(:,1),seg{si}(:,2),labelColor(label(si)));hold off;
    set(gca,'YDir','Reverse');
end
for ci = 1:length(cntrInd)
    hold on;plot(seg{cntrInd(ci)}(:,1),seg{cntrInd(ci)}(:,2),[labelColor(ci),'o']);hold off;
    set(gca,'YDir','Reverse');
end

figure(11);
plot(1:length(y1),y1,'b.',1:length(y2),y2,'g^',1:length(y3),y3,'r*',1:length(y4),y4,'ms');
legend y1 y2 y3 y4
