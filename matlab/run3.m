function s = run3(data3, a1, a2, b1, b2, theta, delta, solution)
s = true;

% data3 = xlsread('append1.xlsx');
% a1 = 25;
% a2 = 15; % ��ֱ���У����Ҫ��ֱ���<a1, ˮƽ���<a2
% b1 = 20;
% b2 = 25; % ˮƽ���У����Ҫ��ֱ���<b1, ˮƽ���<b2
% theta = 30;
% delta = 0.001;

data3 = xlsread('append2.xlsx');
a1 = 20;
a2 = 10; % ��ֱ���У����Ҫ��ֱ���<a1, ˮƽ���<a2
b1 = 15;
b2 = 20; % ˮƽ���У����Ҫ��ֱ���<b1, ˮƽ���<b2
theta = 20;
delta = 0.001;
% solution = [0   163   114     8   309   305   123    45   160   191    92    93    61   292   326];
now_error = [0 0];
length = 0;

for i = 1:size(solution, 2) - 2
%     if (solution(i + 1) == 60 || solution(i + 1) == 190)
%         p1 = 0;
%     else
        p1 = 1;
%     end
    length = length + norm(data3(solution(i) + 1, 2:4) - data3(solution(i + 1) + 1, 2:4));
    now_error = now_error + delta * norm(data3(solution(i) + 1, 2:4) - data3(solution(i + 1) + 1, 2:4));
    if (data3(solution(i + 1) + 1, 5) == 1)
        if (now_error(1) <= a1 && now_error(2) <= a2)
%             fprintf('%d -> %d����ֱУ���㣬У��ǰ��ֱ��%f��У��ǰˮƽ��%f��', solution(i), solution(i + 1), now_error(1), now_error(2));
            p = rand();
            if (data3(solution(i + 1) + 1, 6) == 1 && p1 < 0.2)
                now_error(1) = min([5 now_error(1)]);
%                 fprintf('У��ʧ�ܣ�У����ֱ��%f��У����ˮƽ��%f\n', now_error(1), now_error(2));
            else
                now_error(1) = 0;
%                 fprintf('У���ɹ���У����ֱ��%f��У����ˮƽ��%f\n', now_error(1), now_error(2));
            end
        else
            s = false;
%             disp('����ʧ��');
            break;
        end
    end
    if (data3(solution(i + 1) + 1, 5) == 0)
        if (now_error(1) <= b1 && now_error(2) <= b2)
%             fprintf('%d -> %d��ˮƽУ���㣬У��ǰ��ֱ��%f��У��ǰˮƽ��%f��', solution(i), solution(i + 1), now_error(1), now_error(2));
            p = rand();
            if (data3(solution(i + 1) + 1, 6) == 1 && p1 < 0.2)
                now_error(2) = min([5 now_error(2)]);
%                 fprintf('У��ʧ�ܣ�У����ֱ��%.2f��У����ˮƽ��%.2f\n', now_error(1), now_error(2));
            else
                now_error(2) = 0;
%                 fprintf('У���ɹ���У����ֱ��%.2f��У����ˮƽ��%.2f\n', now_error(1), now_error(2));
            end
        else
            s = false;
%             disp('����ʧ��');
            break;
        end
    end
end
length = length + norm(data3(solution(i + 1) + 1, 2:4) - data3(solution(i + 2) + 1, 2:4));
now_error = now_error + delta * norm(data3(solution(i + 1) + 1, 2:4) - data3(solution(i + 2) + 1, 2:4));
if (now_error(1) <= theta && now_error(2) <= theta)
%     fprintf('%d -> %d���յ㣬У��ǰ��ֱ��%.2f��У��ǰˮƽ��%.2f�������ɹ���\n', solution(i + 1), solution(i + 2), now_error(1), now_error(2));
else
    s = false;
%     disp('����ʧ��');
end
% fprintf('%.f\n', length);
end