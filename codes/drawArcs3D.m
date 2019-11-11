function arc_points = drawArcs3D(bound_vector1, bound_vector2, base_vector)
%     ���������߽������ҵ�����������Χ��Բ���ϵĵ�
    length = (norm(bound_vector1) + norm(bound_vector2)) / 2;
    arc_points = [];
    for i = 0:0.01:1
        ori = bound_vector1 * i + bound_vector2 * (1 - i);
        arc_points = [arc_points; ori / norm(ori) * length + base_vector];
    end
end

