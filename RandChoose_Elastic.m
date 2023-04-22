function [migFlag,migPMNo] = RandChoose_Elastic(serviceChainCell, CPUResource,MemoryResource,BandwidthResource,row,NFVNo,NFVnewXXXNum,elasticNo,PMNum)
%  随机选择一个PM作为转移，最多随机10次，如果10次找到的全爆满，则不迁移了
%row表示需要迁移的chain所在行数
migFlag = 0;     %migFlag = 0表示没找到合适PM
serviceChain_vec = serviceChainCell(row,:);
% 1：NFV数量；2：部署在哪些PM上了；3：NFV需要的CPU数；4：需要的Mem数；
% 5：NFV间带宽需求；6：业务生命周期；7：业务链初始编号

%     访问对应NFV的资源数量
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
   在Bnd迁移需求的时候，需要调度的包括IN和OUT
end
% elasticNo = 1, 3, 5 表示CPU，Mem，Bnd弹性需求
for i = 1 : 10
%     随机一个PM
    newPMNo = randi([1 PMNum]);
%     检查这个PM资源是否能够承受NFV的资源
    PM_CPUResource = CPUResource(newPMNo);
    PM_MemResource = MemoryResource(newPMNo);
    PM_BndResource_from = BandwidthResource(newPmNo);

    
    
    
end


migPMNo = 0;
end