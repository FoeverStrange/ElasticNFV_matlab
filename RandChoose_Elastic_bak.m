function [migFlag,migPMNo] = RandChoose_Elastic(serviceChainCell, CPUResource,MemoryResource,BandwidthResource,row,NFVNo,NFVnewXXXNum,elasticNo,PMNum)
%  随机选择一个PM作为转移，最多随机10次，如果10次找到的全爆满，则不迁移了
%row表示需要迁移的chain所在行数
migFlag = 0;     %migFlag = 0表示没找到合适PM
migPMNo = -1;
serviceChain_vec = serviceChainCell(row,:);
% 1：NFV数量；2：部署在哪些PM上了；3：NFV需要的CPU数；4：需要的Mem数；
% 5：NFV间带宽需求；6：业务生命周期；7：业务链初始编号

%     访问对应NFV的资源数量
NFVCPU_vec = serviceChain_vec{3};
NFVCPUNum = NFVCPU_vec(NFVNo);
NFVMem_vec = serviceChain_vec{4};
NFVMemNum = NFVMem_vec(NFVNo);
NFVBnd_vec = serviceChain_vec{5};

if (elasticNo == 1 || elasticNo == 3)
    if elasticNo == 1
        NFVCPUNum = NFVnewXXXNum;
    end
    if elasticNo == 3
        NFVMemNum = NFVnewXXXNum; 
    end
    for i = 1 : 10
%     随机一个PM
        newPMNo = randi([1 PMNum]);
%     检查这个PM资源是否能够承受NFV的资源
        PM_CPUResource = CPUResource(newPMNo);
        if (NFVCPUNum > PM_CPUResource)
            %                 不满足要求
                continue
        end
        PM_MemResource = MemoryResource(newPMNo);
        if (NFVMemNum > PM_MemResource)
            %                 不满足要求
                continue
        end
        PMNo_vec = serviceChain_vec{2};
        if NFVNo > 1        %当不是第一个NFV的时候，考虑上一个NFV的传过来的带宽
            oldPMNo_from = PMNo_vec(NFVNo - 1);
            PM_BndResource_IN = BandwidthResource(oldPMNo_from,newPMNo);
            NFVBnd_from = NFVBnd_vec(NFVNo - 1);
            if (NFVBnd_from > PM_BndResource_IN)
%                 不满足要求
                continue
            end
        end
        if NFVNo < length(PMNo_vec)%当不是最后一个NFV的时候，考虑传给下个一NFV的带宽
            oldPMNo_to = PMNo_vec(NFVNo + 1);
            PM_BndResource_OUT = BandwidthResource(newPMNo,oldPMNo_to);
            NFVBnd_to = NFVBnd_vec(NFVNo);
            if (NFVBnd_to > PM_BndResource_OUT)
%                 不满足要求
                continue
            end
        end
        migFlag = 1;
        migPMNo = newPMNo;
        break

    end
else
    if elasticNo == 5
        NFVBnd_from = NFVnewXXXNum; 
        for i = 1 : 10
%     随机一个PM
            newPMNo = randi([1 PMNum]);
%     检查这个PM资源是否能够承受NFV的资源
            PM_CPUResource = CPUResource(newPMNo);
            if (NFVCPUNum > PM_CPUResource)
            %                 不满足要求
                    continue
            end
            PM_MemResource = MemoryResource(newPMNo);
            if (NFVMemNum > PM_MemResource)
            %                 不满足要求
                continue
            end
            PMNo_vec = serviceChain_vec{2};
            if NFVNo > 0        %当不是第一个NFV的时候，考虑上一个NFV的传过来的带宽
                oldPMNo_from = PMNo_vec(NFVNo);
                PM_BndResource_IN = BandwidthResource(oldPMNo_from,newPMNo);
%                 NFVBnd_from = NFVBnd_vec(NFVNo);
                if (NFVBnd_from > PM_BndResource_IN)
%                 不满足要求
                    continue
                end
            end
            if NFVNo < (length(PMNo_vec) - 1) %当不是最后一个NFV的时候，考虑传给下个一NFV的带宽
                oldPMNo_to = PMNo_vec(NFVNo + 2);
                PM_BndResource_OUT = BandwidthResource(newPMNo,oldPMNo_to);
                NFVBnd_to = NFVBnd_vec(NFVNo+1);
                if (NFVBnd_to > PM_BndResource_OUT)
%                 不满足要求
                    continue
                end
            end
            migFlag = 1;
            migPMNo = newPMNo;
            break
        end
%         NFVBnd_from = NFVBnd_vec(NFVNo);
%         NFVBnd_to = NFVBnd_vec(NFVNo + 1);
%         NFVBnd_from = NFVnewXXXNum; 
%    在Bnd迁移需求的时候，需要调度的编号与其他迁移需求不同
%         oldPMNo_from = serviceChain_vec{NFVNo};
%         oldPM
    end
end

% elasticNo = 1, 3, 5 表示CPU，Mem，Bnd弹性需求
if (migFlag == 0)
    migPMNo = -1;
end

end