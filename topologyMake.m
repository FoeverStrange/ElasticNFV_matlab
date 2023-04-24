clear
close all;

N = 100; % 节点数目
p = 5/N; % 每个节点与其他节点连接的概率
adj_matrix = zeros(N); % 生成一个100x100的0矩阵，表示节点之间的连接关系

for i = 1:N
    for j = i+1:N
        if rand < p % 如果生成的随机数小于p，即两个节点需要连接
            adj_matrix(i,j) = 1; % 将节点i和节点j连接起来
            adj_matrix(j,i) = 1; % 将节点j和节点i连接起来
        end
    end
end

% 可视化拓扑
gplot(adj_matrix, rand(N,2), '-o')
title('100个节点的拓扑图')

B = rand(size(adj_matrix));
% 将随机数矩阵缩放到[20,30]的区间
C = 20 + (30-20)*B;

adj_matrix = adj_matrix .* C;

NODE_TOPOLOGY = adj_matrix;
save('NODE_TOPOLOGY.mat', 'NODE_TOPOLOGY');