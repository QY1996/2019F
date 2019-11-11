% ���㵱ǰ�⾭���ĵ㡢��·�����ȡ�ÿһ�㵽������ÿһ��Ľ��Ŷ�

function solution_detail = calculate_solution_detail(data3, original_solution, a1, a2, b1, b2, theta, delta)
    solution_detail = struct();
    point_counts = size(original_solution, 2);
    points = data3(original_solution + 1, 2:6);
    errors = [0 0];
    all_distance = 0;
%     ����õ�ʱ���õ��Ӧ�������������֮�ԽСԽ����
    tenses = [inf];
    for i = 1:point_counts - 1
        distance = norm(points(i, 1:3) - points(i + 1, 1:3));
        if (points(i + 1, 4) == 1)
            error = [0 errors(i, 2) + distance * delta];
            errors = [errors; error];
            tenses = [tenses a1 - errors(i + 1, 1) - distance * delta];
        elseif (points(i + 1, 4) == 0)
            error = [errors(i, 1) + distance * delta 0];
            errors = [errors; error];
            tenses = [tenses b2 - errors(i + 1, 2) - distance * delta];
        else
            error = [errors(i, 1) + distance * delta errors(i, 2) + distance * delta];
            errors = [errors; error];
            tenses = [tenses inf];
        end
        all_distance = all_distance + distance;
    end
    solution_detail.length = all_distance;
    solution_detail.points = points;
    solution_detail.errors = errors;
    solution_detail.tense = tenses;
end

