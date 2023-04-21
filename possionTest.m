lambda = 0.36; % 指定泊松过程的强度参数
T = 100; % 模拟的时间长度
N = poissrnd(lambda*T); % 生成符合泊松分布的随机事件数量

% 生成符合指数分布的随机事件间隔时间
interarrival_times = exprnd(1/lambda, [N, 1]);

% 计算每个随机事件的时间戳
timestamps = cumsum(interarrival_times);

% 绘制泊松过程图形
figure;
stairs([0; timestamps], [0; (1:N)'], 'LineWidth', 2);
xlim([0, T]);
xlabel('时间');
ylabel('事件数量');
title(['泊松过程 (\lambda = ', num2str(lambda), ')']);
