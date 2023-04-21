function [migFlag,migPMNo] = RandChoose_Elastic(serviceChainCell, CPUResource,MemoryResource,BandwidthResource,row,NFVNo,NFVnewCPUNum,elasticNo)
%  随机选择一个PM作为转移，最多随机10次，如果10次找到的全爆满，则不迁移了
%row表示需要迁移的chain所在行数
migFlag = 0;     %migFlag = 0表示没找到合适PM
% elasticNo = 1, 3, 5 表示CPU，Mem，Bnd弹性需求
for i = 1 : 10
    
end


migPMNo = 0;
end