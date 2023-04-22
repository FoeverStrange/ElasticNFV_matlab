            else
%                 CPU不足
%               随机选择一个PM作为转移，最多随机10次，如果10次找到的全爆满，则不迁移了
                [migFlag,migPMNo] = RandChoose_Elastic(serviceChainCell, CPUResource,MemoryResource,BandwidthResource,row,NFVNo,NFVnewCPUNum,elasticNo);  %row表示需要迁移的chain所在行数
%               计算QRP QMP
%                   未来QMP根据卸载决策计算
                RefuseNum = NFVdeltaCPUNum - CPUResource(PMNum);
                RequestNum = NFVnewCPUNum;
                QRP = QRPComputing(RequestNum, RefuseNum);
                oldServiceTime = DEFINE_SERVICETIME;
                NFVData = DEFINE_NFVDATA;
                CommuSpeed = DEFINE_COMMUSPEED;
                serviceLifetime = serviceChainCell{row, 6};
                serviceTimeUp = DEFINE_SERVICETIME_UP;
                QMP = QMPComputing(oldServiceTime,NFVData,CommuSpeed,serviceLifetime,serviceTimeUp);
                disp(['CPU 不足，QRP = ',num2str(QRP),'; QMP = ',num2str(QMP)])
                if(QMP < QRP)
%                     开始迁移
                    l=0;
                    for l=1:3
                        for ？% L层每一个放置有r中VNF的节点v
                            if l=0
                               ？            %r中在v中的VNF放入第一集合Wv 
                               Sv=0         %Sv置零
                               (Wv,Sv)=SettleInServer       %调用SettleInServer函数
                            else
                               (Wv,Sv)=SettleInSwitch       %调用SettleInSwitch函数
                            if size(Sv)==number(VNFs of r)
                                return true
                            else if l==3
                                    ？   %回滚到执行前的状态
                                    return false
                            else %上传等待集和已结算集
                                v'=v的父节点
                                Wv'+= Wv
                                Sv'+=Sv
                            l=l+1
                  return true














                    disp('选择迁移')
%                     migFlag,migPMNo
                else
%                     忍受QRP
                    disp('选择忍受')
%                     CPUResource(PMNum) = 0;
%                     CPUResource(PMNum) - NFVdeltaCPUNum;
                    newCPUNum_vec = oldCPUNum_vec;
                    newCPUNum_vec(NFVNo) = newCPUNum_vec(NFVNo) + CPUResource(PMNum);
                    serviceChainCell{row, 3} = newCPUNum_vec;
                    CPUResource(PMNum) = 0;
                    totalPenalty = totalPenalty + QRP;
                end
