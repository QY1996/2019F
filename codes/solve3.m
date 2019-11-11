% ����3��������

clc;
clear all;
data3 = xlsread('append1.xlsx');
a1 = 25;
a2 = 15; % ��ֱ���У����Ҫ��ֱ���<a1, ˮƽ���<a2
b1 = 20;
b2 = 25; % ˮƽ���У����Ҫ��ֱ���<b1, ˮƽ���<b2
theta = 30;
delta = 0.001;

% data3 = xlsread('append2.xlsx');
% a1 = 20;
% a2 = 10; % ��ֱ���У����Ҫ��ֱ���<a1, ˮƽ���<a2
% b1 = 15;
% b2 = 20; % ˮƽ���У����Ҫ��ֱ���<b1, ˮƽ���<b2
% theta = 20;
% delta = 0.001;

original_solution = [0   521    64    80   170   278   369   214   397   612];
% original_solution = [0   252   266   100   137   194   126    47   205   258   250    86    73    39   274    12   216   279   301    61   292   326];

% ��������
solution = original_solution;
point_counts = size(solution, 2);
max_iter = 1000;
jiejin = 100; % ���ɱ���
insert_number = 0; % �ɳڵ����
scores = [];
forbidden = zeros(size(data3, 1) - 2); % ���ɱ�
solution_detail = calculate_solution_detail(data3, solution, a1, a2, b1, b2, theta, delta);
[success_rate, false_index_sort] = calculate_success_rate(data3, solution, a1, a2, b1, b2, theta, delta);
score = solution_detail.length + 1e5 / success_rate;
scores = [scores score];
for it = 1:max_iter
    cant_find_better_solution = true;

    to_change_order = false_index_sort;
    for i = 2:size(solution, 2) - 1
        if (~ismember(solution(i), false_index_sort))
            to_change_order = [to_change_order; solution(i)];
        end
    end

%     ���е�Ĳ���
    if (insert_number > 0)
        insert_number = insert_number - 1;
        tc_index = ceil((size(solution, 2) - 1) * rand());
        after_index = tc_index + 1;

        min_sum_length = inf;
        for i = 2:size(data3, 1) - 1
            n_point = data3(i, 2:4);
            sum_length = norm(solution_detail.points(tc_index, 1:3) - n_point) + norm(solution_detail.points(after_index, 1:3) - n_point);
            if (sum_length < min_sum_length && ~ismember(i - 1, solution))
                min_sum_length = sum_length;
                best_insert = i - 1;
            end
        end

        solution = [solution(1:tc_index) best_insert solution(tc_index + 1:size(solution, 2))];
        solution_detail = calculate_solution_detail(data3, solution, a1, a2, b1, b2, theta, delta);
        [success_rate, false_index_sort] = calculate_success_rate(data3, solution, a1, a2, b1, b2, theta, delta);
        score = solution_detail.length + 1 / success_rate * 1e5;
        scores = [scores score];
        continue;
    end

    for idx = 1:size(to_change_order, 1)
        to_be_changed = to_change_order(idx);
        tc_index = find(solution == to_be_changed);
        before_index = tc_index-1;
        before_error = solution_detail.errors(before_index, :);
        after_index = tc_index+1;
    %     Ѱ������
        changeable = [];
        for i = 2:size(data3, 1) - 1
            index = i - 1;
            n_point = data3(i, 2:4);
            if (data3(i, 5) == 1)
                flag1 = before_error(1) + norm(n_point - solution_detail.points(before_index, 1:3)) * delta < a1;
                flag2 = before_error(2) + norm(n_point - solution_detail.points(before_index, 1:3)) * delta < a2;
                if (solution_detail.points(after_index, 4) == 1)
                    flag3 = norm(n_point - solution_detail.points(after_index, 1:3)) * delta < a1;
                    flag4 = before_error(2) + norm(n_point - solution_detail.points(before_index, 1:3)) * delta + norm(n_point - solution_detail.points(after_index, 1:3)) * delta < a2;
                else
                    flag3 = norm(n_point - solution_detail.points(after_index, 1:3)) * delta < b1;
                    flag4 = before_error(2) + norm(n_point - solution_detail.points(before_index, 1:3)) * delta + norm(n_point - solution_detail.points(after_index, 1:3)) * delta < b2;
                end
            else
                flag1 = before_error(1) + norm(n_point - solution_detail.points(before_index, 1:3)) * delta < b1;
                flag2 = before_error(2) + norm(n_point - solution_detail.points(before_index, 1:3)) * delta < b2;
                if (solution_detail.points(after_index, 4) == 1)
                    flag3 = before_error(1) + norm(n_point - solution_detail.points(before_index, 1:3)) * delta + norm(n_point - solution_detail.points(after_index, 1:3)) * delta < a1;
                    flag4 = norm(n_point - solution_detail.points(after_index, 1:3)) * delta < a2;
                else
                    flag3 = before_error(1) + norm(n_point - solution_detail.points(before_index, 1:3)) * delta + norm(n_point - solution_detail.points(after_index, 1:3)) * delta < b1;
                    flag4 = norm(n_point - solution_detail.points(after_index, 1:3)) * delta < b2;
                end
            end
            flag6 = ~(ismember(index, solution));
            if (flag1 && flag2 && flag3 && flag4 && flag6)
                changeable = [changeable index];
            end
        end

    %     �滻�����۽�ĺû�
        best_score = score;
        best_solution = solution;
        best_index = 0;
        for i = 1:size(changeable, 2)
            temp_solution = solution;
            temp_solution(tc_index) = changeable(i);
            [s_rate, temp_false_index_sort] = calculate_success_rate(data3, temp_solution, a1, a2, b1, b2, theta, delta);
            temp_detail = calculate_solution_detail(data3, temp_solution, a1, a2, b1, b2, theta, delta);
            temp_score = temp_detail.length + 1e5 / s_rate;
            p = rand();
%             �������ã������
            if (temp_score < best_score || (p < (max_iter - it) * 2e-4))
%                 ����ڽ��ɱ��У�������ʷ���Ž�ã����ƽ�
                if (forbidden(to_be_changed, changeable(i)) == 0 || temp_score < all_best_score)
                    best_score = temp_score;
                    best_solution = temp_solution;
                    best_index = changeable(i);
                    best_detail = temp_detail;
                    best_false_index_sort = temp_false_index_sort;
                end
                if (temp_score < all_best_score)
                    all_best_score = temp_score;
                    all_best_solution = temp_solution;
                end
            end
        end
        if (best_index > 0)
            forbidden(forbidden > 0) = forbidden(forbidden > 0) - 1;
            forbidden(to_be_changed, best_index) = jiejin;
            forbidden(best_index, to_be_changed) = jiejin;
            solution = best_solution;
            solution_detail = best_detail;
            false_index_sort = best_false_index_sort;
            score = best_score;
            scores = [scores best_score];
            cant_find_better_solution = false;
            break;
        else
            continue;
        end
    end
    if (cant_find_better_solution)
        break;
    end
end