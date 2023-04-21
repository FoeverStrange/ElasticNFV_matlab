lambda = 0.36; % ָ�����ɹ��̵�ǿ�Ȳ���
T = 100; % ģ���ʱ�䳤��
N = poissrnd(lambda*T); % ���ɷ��ϲ��ɷֲ�������¼�����

% ���ɷ���ָ���ֲ�������¼����ʱ��
interarrival_times = exprnd(1/lambda, [N, 1]);

% ����ÿ������¼���ʱ���
timestamps = cumsum(interarrival_times);

% ���Ʋ��ɹ���ͼ��
figure;
stairs([0; timestamps], [0; (1:N)'], 'LineWidth', 2);
xlim([0, T]);
xlabel('ʱ��');
ylabel('�¼�����');
title(['���ɹ��� (\lambda = ', num2str(lambda), ')']);
