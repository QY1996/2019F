clc;
clear all;
% % 计算每一步的平均长度和角度
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

% 测试：无人机转弯是否应该从起点开始？

theta = pi / 6;
l = 10000;
r = 200;
alpha = 0 : 0.01 : pi - theta;
v = zeros(1, size(alpha, 2));
for i = 1:size(alpha, 2)
    v(i) = cal(theta, alpha(i), l, r);
end
plot(alpha, v);

xlabel("ω'/rad");
ylabel('路径长度/m');
function v = cal(theta, alpha, l, r)
    v = l * (sin(theta) / sin(alpha) + sin(alpha + theta) / sin(alpha)) - r * (2 * tan((pi - alpha) / 2) - pi + alpha);
end

% % 测试：无人机的转弯半径是否越小越好？
% point1 = [0 0 0];
% point2 = [10000 0 0];
% inVector = [cos(18 / pi) sin(18 / pi) 0];
% r = 200:1:5000;
% l = zeros(1, size(r, 2));
% for i = 1:size(r, 2)
%     l(i) = calculateLength2(point1, point2, inVector, r(i));
% end
% plot(r, l);
% xlabel('圆的半径/m');
% ylabel('路径长度/m');