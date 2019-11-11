clc;
clear all;
% data1 = xlsread('append1.xlsx');
% a1 = 25;
% a2 = 15; % ��ֱ���У����Ҫ��ֱ���<a1, ˮƽ���<a2
% b1 = 20;
% b2 = 25; % ˮƽ���У����Ҫ��ֱ���<b1, ˮƽ���<b2
% theta = 30;
% delta = 0.001;
% 
data1 = xlsread('append2.xlsx');
a1 = 20;
a2 = 10; % ��ֱ���У����Ҫ��ֱ���<a1, ˮƽ���<a2
b1 = 15;
b2 = 20; % ˮƽ���У����Ҫ��ֱ���<b1, ˮƽ���<b2
theta = 20;
delta = 0.001;
max_error = [a1 a2];
pointCounts = size(data1, 1);
pointA = data1(1, 2:4);
pointB = data1(pointCounts, 2:4);
% ����У������У��������
error_points = data1(2:pointCounts-1, 2:4);
error_types = data1(2:pointCounts-1, 5);
pointCounts = pointCounts - 2;
% % �������
% distance_matrix = zeros(pointCounts);
% for i = 1:pointCounts
%     for j = 1:pointCounts
%         if i == j
%             distance_matrix(i, j) = inf;
%         else
%             distance_matrix(i, j) = norm(error_points(i, :) - error_points(j, :));
%         end
%     end
% end
% ��ǰ�����������
tic;
flag = true;
while(flag)
%     p = 0.9869;
    p = 0.5707;
    now_error = zeros(1, 2);
    now_point = pointA;
    step = 0;
    road_point = [];
    road_point = [road_point; pointA];
    road_index = [];
    road_index = [road_index; 0];
    history_forbidden = [];
    while(norm(now_point - pointB) * delta + now_error(1) > theta || norm(now_point - pointB) * delta + now_error(2) > theta)
        %     Ѱ�ҿ��õ㣬�������
        available_points = [];
        available_types = [];
        available_lengths = [];
        available_anglescos = [];
        for i = 1:pointCounts
            flag = true;
            for m = 1:size(history_forbidden, 1)
                if (all(error_points(i, :) == history_forbidden(m, :)))
                    flag = false;
                end
            end
            if (~all(now_point == error_points(i, :)) && flag)
                if (error_types(i) == 1)
                    if (norm(now_point - error_points(i, :)) * delta + now_error(1) < a1 && norm(now_point - error_points(i, :)) * delta + now_error(2) < a2)
                        available_points = [available_points; error_points(i, :)];
                        available_types = [available_types 1];
                        available_lengths = [available_lengths norm(now_point - error_points(i, :))];
                        available_anglescos = [available_anglescos dot(pointB - now_point, error_points(i, :) - now_point) / norm(pointB - now_point) / norm(error_points(i, :) - now_point)];
                    end
                else
                    if (norm(now_point - error_points(i, :)) * delta + now_error(1) < b1 && norm(now_point - error_points(i, :)) * delta + now_error(2) < b2)
                        available_points = [available_points; error_points(i, :)];
                        available_types = [available_types 0];
                        available_lengths = [available_lengths norm(now_point - error_points(i, :))];
                        available_anglescos = [available_anglescos dot(pointB - now_point, error_points(i, :) - now_point) / norm(pointB - now_point) / norm(error_points(i, :) - now_point)];
                    end
                end
            end
        end
        %     �����Ŀ�����
        a_cnt = size(available_points, 1);
        available = zeros(1, a_cnt);
        for i = 1:a_cnt
            for j = 1:pointCounts
                if (~all(available_points(i, :) == error_points(j, :)))  
                    if (available_types(i) == 0)
                        if (error_types(j) == 1 && (norm(available_points(i, :) - error_points(j, :)) + available_lengths(i)) * delta + now_error(1) < a1)
                            available(i) = 1;
                            break;
                        end
                    else
                        if (error_types(j) == 0 && (norm(available_points(i, :) - error_points(j, :)) + available_lengths(i)) * delta + now_error(2) < b2)
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

        if(size(available_points, 1) == 0)
            disp('����');
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
        %         ������Ӧ��
        %         ������Ŷ�
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
        fprintf('��%d������ǰ�����꣺%f��%f��%f ,��ǰ��ֱ��%f����ǰˮƽ��%f\n', step, now_point(1), now_point(2), now_point(3), before(1), before(2));
        if step > 100
            break;
        end
    end
    now_error(1) = now_error(1) + norm(pointB - now_point) * delta;
    now_error(2) = now_error(2) + norm(pointB - now_point) * delta;
    step = step + 1;
    now_point = pointB;
    road_point = [road_point; now_point];
    fprintf('��%d������ǰ�����꣺%f��%f��%f ,��ǰ��ֱ��%f����ǰˮƽ��%f\n', step, now_point(1), now_point(2), now_point(3), now_error(1), now_error(2));

    % ���㳤��
    length = 0;
    for i = 1:size(road_point, 1) - 1
    length = length + norm(road_point(i, :) - road_point(i + 1, :));
    end
    fprintf('�ܳ��ȣ�%f\n', length);
    
    flag = false;
end

toc;

% ��������
% save('solve1_1.mat', 'best_road');
% save('solve1_2.mat', 'best_road');