clc;
clear all;
% data3 = xlsread('append1.xlsx');
% a1 = 25;
% a2 = 15; % 垂直误差校正需要垂直误差<a1, 水平误差<a2
% b1 = 20;
% b2 = 25; % 水平误差校正需要垂直误差<b1, 水平误差<b2
% theta = 30;
% delta = 0.001;

data3 = xlsread('append2.xlsx');
a1 = 20;
a2 = 10; % 垂直误差校正需要垂直误差<a1, 水平误差<a2
b1 = 15;
b2 = 20; % 水平误差校正需要垂直误差<b1, 水平误差<b2
theta = 20;
delta = 0.001;

% original_solution = [0   521    64    80   170   278   369   214   397   612];% 附件1最优初始解
original_solution = [0   163   114     8   309   121   123    49   160    92    93    61   292   326]; % 附件2最优初始解
% original_solution = [0   252   266   100   137   194   126    47   205   258   250    86    73    39   274    12   216   279   301    61   292   326]; % 附件2 改进初始解
% original_solution = [0   169   322   100    60   137   194   190   151    36   296   250   243    73   249   274    12   216   279   301    38   110    99   326];

history_best_rate = 0;
history_best_score = inf;
for iterator = 1:50000

    % 禁忌搜索
    solution = original_solution;
    all_best_solution = solution;
    point_counts = size(solution, 2);
    max_iter = 1000;
    jiejin = 100;
    insert_number = 1;
    scores = [];
    forbidden = zeros(size(data3, 1) - 2);
    solution_detail = calculate_solution_detail(data3, solution, a1, a2, b1, b2, theta, delta);
    score = solution_detail.length;
    scores = [scores score];
    all_best_score = inf;
    for it = 1:max_iter
        cant_find_better_solution = true;
        Idx = randperm(size(solution, 2) - 2);
        to_change_order = solution(Idx + 1);

        if (insert_number > 0)
            insert_number = insert_number - 1;
    %         tc_index = find(solution == false_index_sort(1));
    %         after_index = tc_index + 1;
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
            score = solution_detail.length;
            scores = [scores score];
            continue;
        end

        for idx = 1:size(to_change_order, 1)
            to_be_changed = to_change_order(idx);
            tc_index = find(solution == to_be_changed);
            before_index = tc_index-1;
            before_error = solution_detail.errors(before_index, :);
            after_index = tc_index+1;
        %     寻找邻域
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

        %     替换并评价解的好坏
            best_score = score;
            best_solution = solution;
            best_index = 0;
            for i = 1:size(changeable, 2)
                temp_solution = solution;
                temp_solution(tc_index) = changeable(i);
                temp_detail = calculate_solution_detail(data3, temp_solution, a1, a2, b1, b2, theta, delta);
                temp_score = temp_detail.length;
                p = rand();
                if (temp_score < best_score || (p < (max_iter - it) * 2e-4))
                    if (forbidden(to_be_changed, changeable(i)) == 0 || temp_score < all_best_score)
                        best_score = temp_score;
                        best_solution = temp_solution;
                        best_index = changeable(i);
                        best_detail = temp_detail;
%                         fprintf('%d -> %d\n', tc_index, changeable(i));
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
%     disp(all_best_solution);
    d = calculate_solution_detail(data3, all_best_solution, a1, a2, b1, b2, theta, delta);

    if (d.length < history_best_score)
        history_best_score = d.length;
        disp(all_best_solution);
        disp(history_best_score);
    end
end