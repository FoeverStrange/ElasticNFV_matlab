function [migFlag,migPMNo] = RandChoose_Elastic(serviceChainCell, CPUResource,MemoryResource,BandwidthResource,row,NFVNo,NFVnewXXXNum,elasticNo,PMNum)
%  ���ѡ��һ��PM��Ϊת�ƣ�������10�Σ����10���ҵ���ȫ��������Ǩ����
%row��ʾ��ҪǨ�Ƶ�chain��������
migFlag = 0;     %migFlag = 0��ʾû�ҵ�����PM
serviceChain_vec = serviceChainCell(row,:);
% 1��NFV������2����������ЩPM���ˣ�3��NFV��Ҫ��CPU����4����Ҫ��Mem����
% 5��NFV���������6��ҵ���������ڣ�7��ҵ������ʼ���

% elasticNo = 1, 3, 5 ��ʾCPU��Mem��Bnd��������
for i = 1 : 10
%     ���һ��PM
    newPMNo = randi([1 PMNum]);
%     ������PM��Դ�Ƿ��ܹ�����NFV����Դ
    
end


migPMNo = 0;
end