% 用于第二问，根据入射角、起点、终点和转弯半径计算两点间的最短距离、转弯圆心O与直线与圆的切点C

function [length, O, C]= calculateLength2(point1, point2, inVector, r)
    % 起点为A的情况
    if (all(inVector == [0 0 0]))
        length = norm(point2 - point1);
        O = (point2 - point1) / length * r;
        C = point1;
    else
%         根据几何公式计算相应的数据
        lineVector = point2 - point1;
        l = norm(lineVector);
        varphi = acos(dot(inVector, lineVector) / norm(inVector) / l);
        l1 = r * sin(varphi);
        l2 = l - l1;
        l3 = sqrt(l2 ^ 2 + r ^ 2 - l1 ^ 2);
        l4 = sqrt(l3 ^ 2 - r ^ 2);
        a3 = acos(l4 / l3);
        a4 = acos(l2 / l3);
        a2 = a3 - a4;
        a1 = varphi + a2;
        length = r * a1 + l4;
        l5 = l1 + r * cos(varphi) * tan(a2);
        AD = lineVector / l * l5;
        n = cross(inVector, lineVector);
        AO = cross(n, inVector);
        AO = AO / norm(AO) * r;
        O = point1 + AO;
        OD = -AO + AD;
        OC = OD / norm(OD) * r;
        C = O + OC;
    end
end

