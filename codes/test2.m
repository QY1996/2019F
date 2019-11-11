clc;
clear all;
% % ����ÿһ����ƽ�����ȺͽǶ�
% road = load('solve1_2.mat');
% road = road.best_road;
% length = 0;
% angle = 0;
% for i = 1:size(road, 1) - 1
%     length = length + norm(road(i, :) - road(i + 1, :));
% end
% 
% for i = 1:size(road, 1) - 2
%     angle = angle + acos(dot(road(i + 1, :) - road(i, :), road(i + 2, :) - road(i + 1, :)) / norm(road(i + 1, :) - road(i, :)) / norm(road(i + 2, :) - road(i + 1, :)));
% end
% 
% fprintf('%f\n', length / (size(road, 1) - 1));
% angle / (size(road, 1) - 2) * 180 / pi

% ���ԣ����˻�ת���Ƿ�Ӧ�ô���㿪ʼ��

theta = pi / 6;
l = 10000;
r = 200;
alpha = 0 : 0.01 : pi - theta;
v = zeros(1, size(alpha, 2));
for i = 1:size(alpha, 2)
    v(i) = cal(theta, alpha(i), l, r);
end
plot(alpha, v);

xlabel("��'/rad");
ylabel('·������/m');
function v = cal(theta, alpha, l, r)
    v = l * (sin(theta) / sin(alpha) + sin(alpha + theta) / sin(alpha)) - r * (2 * tan((pi - alpha) / 2) - pi + alpha);
end

% % ���ԣ����˻���ת��뾶�Ƿ�ԽСԽ�ã�
% point1 = [0 0 0];
% point2 = [10000 0 0];
% inVector = [cos(18 / pi) sin(18 / pi) 0];
% r = 200:1:5000;
% l = zeros(1, size(r, 2));
% for i = 1:size(r, 2)
%     l(i) = calculateLength2(point1, point2, inVector, r(i));
% end
% plot(r, l);
% xlabel('Բ�İ뾶/m');
% ylabel('·������/m');