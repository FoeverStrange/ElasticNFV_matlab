function [migFlag,migPMNo] = RandChoose_Elastic(serviceChainCell, CPUResource,MemoryResource,BandwidthResource,row,NFVNo,NFVnewXXXNum,elasticNo,PMNum)
%  ���ѡ��һ��PM��Ϊת�ƣ�������10�Σ����10���ҵ���ȫ��������Ǩ����
%row��ʾ��ҪǨ�Ƶ�chain��������
migFlag = 0;     %migFlag = 0��ʾû�ҵ�����PM
serviceChain_vec = serviceChainCell(row,:);
% 1��NFV������2����������ЩPM���ˣ�3��NFV��Ҫ��CPU����4����Ҫ��Mem����
% 5��NFV���������6��ҵ���������ڣ�7��ҵ������ʼ���

%     ���ʶ�ӦNFV����Դ����
NFVCPU_vec = serviceChain_vec{3};
NFVCPUNum = NFVCPU_vec(NFVNo);
if elasticNo == 1
   NFVCPUNum = NFVnewXXXNum;
end
NFVMem_vec = serviceChain_vec{4};
NFVMemNum = NFVMem_vec(NFVNo);
if elasticNo == 3
   NFVMemNum = NFVnewXXXNum; 
end
NFVBnd_vec = serviceChain_vec{5};
NFVBnd_from = NFVBnd_vec(NFVNo);
NFVBnd_to = NFVBnd_vec(NFVNo + 1);
if elasticNo == 5
   NFVBnd_from = NFVnewXXXNum; 
   ��BndǨ�������ʱ����Ҫ���ȵİ���IN��OUT
end
% elasticNo = 1, 3, 5 ��ʾCPU��Mem��Bnd��������
for i = 1 : 10
%     ���һ��PM
    newPMNo = randi([1 PMNum]);
%     ������PM��Դ�Ƿ��ܹ�����NFV����Դ
    PM_CPUResource = CPUResource(newPMNo);
    PM_MemResource = MemoryResource(newPMNo);
    PM_BndResource_from = BandwidthResource(newPmNo);

    
    
    
end


migPMNo = 0;
end