% 问题1的可视化

data1 = xlsread('append2.xlsx');
road = load('solve1_2.mat');
road = road.best_road;
X1 = data1(data1(:, 5) == 1, 2);
Y1 = data1(data1(:, 5) == 1, 3);
Z1 = data1(data1(:, 5) == 1, 4);
X0 = data1(data1(:, 5) == 0, 2);
Y0 = data1(data1(:, 5) == 0, 3);
Z0 = data1(data1(:, 5) == 0, 4);

figure
scatter3(X1, Y1, Z1, 5, 'g');
hold on
scatter3(X0, Y0, Z0, 5, 'b');
hold on
plot3(road(:, 1), road(:, 2), road(:, 3), 'm')
hold on
scatter3(road(1, 1), road(1, 2), road(1, 3), [], 'r', 'filled');
text(road(1, 1), road(1, 2), road(1, 3) + 1000, 'A');
hold on
scatter3(road(size(road, 1), 1), road(size(road, 1), 2), road(size(road, 1), 3), [], 'r', 'filled');
text(road(size(road, 1), 1), road(size(road, 1), 2), road(size(road, 1), 3) + 1000, 'B');
axis equal
legend('垂直误差校正点', '水平误差校正点', '航迹');