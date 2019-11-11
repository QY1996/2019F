function [success_rate false_index_sort] = calculate_success_rate(data3, original_solution, a1, a2, b1, b2, theta, delta)
    point_counts = size(original_solution, 2);
    points = data3(original_solution + 1, 2:6);
    dangerous_index = find(points(:, 5) == 1);
    dangerous_counts = size(dangerous_index, 1);
    false_list = [];
    false_rate_list = [];
    
    if(dangerous_counts == 0)
        success_rate = 1;
        return;
    end

    for i = 0:1:2 ^ dangerous_counts - 1
        success = true;
        binstr = dec2bin(i);
        binvec = zeros(1, dangerous_counts);
        for j = 1:dangerous_counts
            if j > size(binstr, 2)
                binvec(j) = 0;
            else
                binvec(j) = str2double(binstr(size(binstr, 2) + 1 - j));
            end
        end

    %     ÄÄĞ©µãÊ§Ğ§
        false_flag = zeros(1, point_counts);
        for j = 1:dangerous_counts
            if (binvec(j) == 1)
                false_flag(dangerous_index(j)) = 1;
            end
        end

        now_point = points(1, 1:3);
        now_error = [0 0];
        for j = 2:point_counts - 1
            distance = norm(points(j, 1:3) - now_point);
            if (points(j, 4) == 1)
                if (now_error(1) + distance * delta > a1 || now_error(2) + distance * delta > a2)
                    success = false;
                    break;
                else
                    now_point = points(j, 1:3);
                    if (false_flag(j) == 1)
                        now_error(1) = min([5 now_error(1) + distance * delta]);
                    else
                        now_error(1) = 0;
                    end
                    now_error(2) = now_error(2) + distance * delta;
                end
            else
                if (now_error(1) + distance * delta > b1 || now_error(2) + distance * delta > b2)
                    success = false;
                    break;
                else
                    now_point = points(j, 1:3);
                    if (false_flag(j) == 1)
                        now_error(2) = min([5 now_error(2) + distance * delta]);
                    else
                        now_error(2) = 0;
                    end
                    now_error(1) = now_error(1) + distance * delta;
                    continue;
                end
            end
        end
        distance = norm(points(point_counts, 1:3) - now_point);
        if (now_error(1) + distance * delta > theta || now_error(2) + distance * delta > theta)
            success = false;
        end
        if (~success)
            p = 1;
            for j = 1:dangerous_counts
                if (binvec(j) == 1)
                    p = p * 0.2;
                else
                    p = p * 0.8;
                end
            end
            false_list = [false_list; binvec];
            false_rate_list = [false_rate_list p];
        end
    end
    success_rate = 1 - sum(false_rate_list);
    if (success_rate <= 0)
        success_rate = 1e-5;
    end
    if (success_rate == 1)
        false_index_sort = [];
        return;
    end
    false_rate_each = zeros(1, dangerous_counts);
    for i = 1:dangerous_counts
        idx = false_list(:, i) == 1;
        false_rate_each(i) = sum(false_rate_list(idx));
    end
    [~, I] = sort(false_rate_each, 'descend');
    false_index_sort = dangerous_index(I);
    real_indexs = data3(original_solution + 1, 1);
    false_index_sort = real_indexs(false_index_sort);
end