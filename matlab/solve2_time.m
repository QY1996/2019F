clc;
clear all;
% data2 = xlsread('append1.xlsx');
% a1 = 25;
% a2 = 15; % 垂直误差校正需要垂直误差<a1, 水平误差<a2
% b1 = 20;
% b2 = 25; % 水平误差校正需要垂直误差<b1, 水平误差<b2
% theta = 30;
% delta = 0.001;

data2 = xlsread('append2.xlsx');
a1 = 20;
a2 = 10; % 垂直误差校正需要垂直误差<a1, 水平误差<a2
b1 = 15;
b2 = 20; % 水平误差校正需要垂直误差<b1, 水平误差<b2
theta = 20;
delta = 0.001;

r = 200;

max_error = [a1 a2];
pointCounts = size(data2, 1);
pointA = data2(1, 2:4);
pointB = data2(pointCounts, 2:4);
% 所有校正点与校正点类型
error_points = data2(2:pointCounts-1, 2:4);
error_types = data2(2:pointCounts-1, 5);
pointCounts = pointCounts - 2;
% 当前飞行器的误差
tic;
flag = true;
while(flag)
%     p = 0.9773;
    p = 0.5982;
    now_error = zeros(1, 2);
    now_point = pointA;
    in_vector = [0 0 0];
    step = 0;
    road_point = [];
    road_point = [road_point; pointA];
    road_index = [];
    road_index = [road_index; 0];
    history_forbidden = [];
    while(calculateLength2(now_point, pointB, in_vector, r) * delta + now_error(1) > theta || calculateLength2(now_point, pointB, in_vector, r) * delta + now_error(2) > theta)
    %     寻找可用点，计算参数
        available_points = [];
        available_types = [];
        available_lengths = [];
        available_anglescos = [];
        available_Cs = [];
        for i = 1:pointCounts
            flag = true;
            for m = 1:size(history_forbidden, 1)
                if (all(error_points(i, :) == history_forbidden(m, :)))
                    flag = false;
                end
            end
            if (~all(now_point == error_points(i, :)) && flag)
                [length, O, C] = calculateLength2(now_point, error_points(i, :), in_vector, r);
                if (error_types(i) == 1)
                    if (length * delta + now_error(1) < a1 && length * delta + now_error(2) < a2)
                        available_points = [available_points; error_points(i, :)];
                        available_types = [available_types 1];
                        available_lengths = [available_lengths length];
                        available_anglescos = [available_anglescos dot(pointB - now_point, error_points(i, :) - now_point) / norm(pointB - now_point) / norm(error_points(i, :) - now_point)];
                        available_Cs = [available_Cs; C];
                    end
                else
                    if (length * delta + now_error(1) < b1 && length * delta + now_error(2) < b2)
                        available_points = [available_points; error_points(i, :)];
                        available_types = [available_types 0];
                        available_lengths = [available_lengths length];
                        available_anglescos = [available_anglescos dot(pointB - now_point, error_points(i, :) - now_point) / norm(pointB - now_point) / norm(error_points(i, :) - now_point)];
                        available_Cs = [available_Cs; C];
                    end
                end
            end
        end
    %     计算点的可行性
        a_cnt = size(available_points, 1);
        available = zeros(1, a_cnt);
        for i = 1:a_cnt
            for j = 1:pointCounts
                if (~all(available_points(i, :) == error_points(j, :)))  
                    if (available_types(i) == 0)
                        if (error_types(j) == 1 && (calculateLength2(available_points(i, :), error_points(j, :), available_points(i, :) - available_Cs(i, :), r) + available_lengths(i)) * delta + now_error(1) < a1)
                            available(i) = 1;
                            break;
                        end
                    else
                        if (error_types(j) == 0 && (calculateLength2(available_points(i, :), error_points(j, :), available_points(i, :) - available_Cs(i, :), r) + available_lengths(i)) * delta + now_error(2) < b2)
                            available(i) = 1;
                            break;
                        end
                    end
                end
            end
        end
        available(available_anglescos < 0) = 0;
        available_points(available == 0, :) = [];
        available_types(available == 0) = [];
        available_lengths(available == 0) = [];
        available_anglescos(available == 0) = [];
        available_Cs(available == 0, :) = [];

        if(size(available_points, 1) == 0)
            disp('回溯');
            history_forbidden = [history_forbidden; now_point];
            now_error = zeros(1, 2);
            now_point = pointA;
            step = 0;
            road_point = [];
            road_point = [road_point; pointA];
            continue;
        end

        a_cnt = size(available_points, 1);
        suits = zeros(1, a_cnt);
        for i = 1:a_cnt
    %         计算适应度
    %         计算紧张度
            if (available_types(i) == 0)
                tense = b2 - now_error(2);
            else
                tense = a1 - now_error(1);
            end
            suits(i) = (p * available_anglescos(i) * 10000 + (1 - p) * available_lengths(i)) / tense;
    %         suits(i) = available_anglescos(i) * available_lengths(i) / tense;
        end
        [M, I] = max(suits);

        now_point = available_points(I, :);
        in_vector = available_points(I, :) - available_Cs(I, :);
        before = [0 0];
        if (available_types(I) == 0)
            before(1) = now_error(1) + available_lengths(I) * delta;
            before(2) = now_error(2) + available_lengths(I) * delta;
            now_error(2) = 0;
            now_error(1) = before(1);
        else
            before(1) = now_error(1) + available_lengths(I) * delta;
            before(2) = now_error(2) + available_lengths(I) * delta;
            now_error(1) = 0;
            now_error(2) = before(2);
        end
        step = step + 1;
        road_point = [road_point; now_point];
        fprintf('第%d步，当前点坐标：%f，%f，%f ,当前垂直误差：%f，当前水平误差：%f\n', step, now_point(1), now_point(2), now_point(3), before(1), before(2));
        if step > 100
            break;
        end
    end
    now_error(1) = now_error(1) + norm(pointB - now_point) * delta;
    now_error(2) = now_error(2) + norm(pointB - now_point) * delta;
    step = step + 1;
    now_point = pointB;
    road_point = [road_point; now_point];
    fprintf('第%d步，当前点坐标：%f，%f，%f ,当前垂直误差：%f，当前水平误差：%f\n', step, now_point(1), now_point(2), now_point(3), now_error(1), now_error(2));

    % 计算长度
    length = 0;
    in_v = [0 0 0];
    for i = 1:size(road_point, 1) - 1
        [l, O, C] = calculateLength2(road_point(i, :), road_point(i + 1, :), in_v, r);
        length = length + l;
        in_v = road_point(i + 1, :) - C;
    end
    fprintf('总长度：%f\n', length);
    flag = false;
end

toc;
% 保存数据
% save('solve2_1.mat', 'best_road');
% save('solve2_2.mat', 'best_road');