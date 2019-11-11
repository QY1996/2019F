% data1 = xlsread('append1.xlsx');
% a1 = 25;
% a2 = 15; % 垂直误差校正需要垂直误差<a1, 水平误差<a2
% b1 = 20;
% b2 = 25; % 水平误差校正需要垂直误差<b1, 水平误差<b2
% theta = 30;
% delta = 0.001;

data1 = xlsread('append2.xlsx');
a1 = 20;
a2 = 10; % 垂直误差校正需要垂直误差<a1, 水平误差<a2
b1 = 15;
b2 = 20; % 水平误差校正需要垂直误差<b1, 水平误差<b2
theta = 20;
delta = 0.001;
solution = [0   169   322   100    60   137   194   190   151    36   296   250   243    73   249   274    12   216   279   301    38   110    99   326];
solution_detail = calculate_solution_detail(data1, solution, a1, a2, b1, b2, theta, delta);
road = solution_detail.points(:, 1:3);
X1 = data1(data1(:, 5) == 1, 2);
Y1 = data1(data1(:, 5) == 1, 3);
Z1 = data1(data1(:, 5) == 1, 4);
X0 = data1(data1(:, 5) == 0, 2);
Y0 = data1(data1(:, 5) == 0, 3);
Z0 = data1(data1(:, 5) == 0, 4);

X2 = data1(data1(:, 6) == 1, 2);
Y2 = data1(data1(:, 6) == 1, 3);
Z2 = data1(data1(:, 6) == 1, 4);

figure
scatter3(X2, Y2, Z2, 32, '^', 'k');
hold on
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
l = legend('可能失败的检查点', '垂直误差校正点', '水平误差校正点', '航迹');
xlabel('x坐标/m');
ylabel('y坐标/m');
zlabel('z坐标/m');
set(l, 'FontSize', 18);