clear
close all;

N = 100; % �ڵ���Ŀ
p = 5/N; % ÿ���ڵ��������ڵ����ӵĸ���
adj_matrix = zeros(N); % ����һ��100x100��0���󣬱�ʾ�ڵ�֮������ӹ�ϵ

for i = 1:N
    for j = i+1:N
        if rand < p % ������ɵ������С��p���������ڵ���Ҫ����
            adj_matrix(i,j) = 1; % ���ڵ�i�ͽڵ�j��������
            adj_matrix(j,i) = 1; % ���ڵ�j�ͽڵ�i��������
        end
    end
end

% ���ӻ�����
gplot(adj_matrix, rand(N,2), '-o')
title('100���ڵ������ͼ')

B = rand(size(adj_matrix));
% ��������������ŵ�[20,30]������
C = 20 + (30-20)*B;

adj_matrix = adj_matrix .* C;

NODE_TOPOLOGY = adj_matrix;
save('NODE_TOPOLOGY.mat', 'NODE_TOPOLOGY');