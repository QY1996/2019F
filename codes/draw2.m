% 问题2的可视化

data1 = xlsread('append2.xlsx');
r = 200;
road = load('solve2_2.mat');
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

in_vector = [0 0 0];
for i = 1:size(road, 1) - 1
    [length, O, C] = calculateLength2(road(i, :), road(i + 1, :), in_vector, r);
    if (all(in_vector == [0 0 0]))
        plot3(road(i:i + 1, 1), road(i:i + 1, 2), road(i:i + 1, 3), 'k');
    else
        arc = drawArcs3D(road(i, :) - O, C - O, O);
        plot3(arc(:, 1), arc(:, 2), arc(:, 3), 'r');
        line = [C; road(i + 1, :)];
        plot3(line(:, 1), line(:, 2), line(:, 3), 'k');
    end
    in_vector = road(i + 1, :) - C;
end

scatter3(road(1, 1), road(1, 2), road(1, 3), [], 'r', 'filled');
text(road(1, 1), road(1, 2), road(1, 3) + 1000, 'A');
hold on
scatter3(road(size(road, 1), 1), road(size(road, 1), 2), road(size(road, 1), 3), [], 'r', 'filled');
text(road(size(road, 1), 1), road(size(road, 1), 2), road(size(road, 1), 3) + 1000, 'B');
axis equal
legend('垂直误差校正点', '水平误差校正点', '直线航迹', '圆弧航迹');