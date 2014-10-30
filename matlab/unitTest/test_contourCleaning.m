load contour_kids

x1 = contour(1).dsca;
x2 = contour(2).dsca;
x1_clean = contour_clean(1).dsca;
x2_clean = contour_clean(2).dsca;
for i=1:20, score(i+9)=hankeletAngle(x1(1:i+9), x2(1:i+9));end
for i=1:20, score_clean(i+9)=hankeletAngle(x1_clean(1:i+9), x2_clean(1:i+9));end
[score; score_clean]

y1 = contour(1).segment;
y2 = contour(2).segment;
y1_clean = contour_clean(1).segment;
y2_clean = contour_clean(2).segment;
for i=1:20, yscore(i+9)=hankeletAngle(y1(1:i+9, :), y2(1:i+9, :));end
for i=1:20, yscore_clean(i+9)=hankeletAngle(y1_clean(1:i+9, :), y2_clean(1:i+9, :));end
[yscore; yscore_clean]

figure;
subplot(221);plot(y1(:,2),y1(:,1),'b');hold on;plot(y1_clean(:,2),y1_clean(:,1),'g');hold off;
xlabel('x axis');ylabel('y axis');title('hstln fitting contour1');
subplot(222);plot(y2(:,2),y2(:,1),'b');hold on;plot(y2_clean(:,2),y2_clean(:,1),'g');hold off;
xlabel('x axis');ylabel('y axis');title('hstln fitting contour2');
subplot(223);plot(x1,'b');hold on;plot(x1_clean,'g');hold off;
xlabel('index');ylabel('derivative of cumulative angle (DCA)');title('DCA1 before and after hstln fitting');
subplot(224);plot(x2,'b');hold on;plot(x2_clean,'g');hold off;
xlabel('index');ylabel('derivative of cumulative angle (DCA)');title('DCA2 before and after hstln fitting');
