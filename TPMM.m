            else
%                 CPU����
%               ���ѡ��һ��PM��Ϊת�ƣ�������10�Σ����10���ҵ���ȫ��������Ǩ����
                [migFlag,migPMNo] = RandChoose_Elastic(serviceChainCell, CPUResource,MemoryResource,BandwidthResource,row,NFVNo,NFVnewCPUNum,elasticNo);  %row��ʾ��ҪǨ�Ƶ�chain��������
%               ����QRP QMP
%                   δ��QMP����ж�ؾ��߼���
                RefuseNum = NFVdeltaCPUNum - CPUResource(PMNum);
                RequestNum = NFVnewCPUNum;
                QRP = QRPComputing(RequestNum, RefuseNum);
                oldServiceTime = DEFINE_SERVICETIME;
                NFVData = DEFINE_NFVDATA;
                CommuSpeed = DEFINE_COMMUSPEED;
                serviceLifetime = serviceChainCell{row, 6};
                serviceTimeUp = DEFINE_SERVICETIME_UP;
                QMP = QMPComputing(oldServiceTime,NFVData,CommuSpeed,serviceLifetime,serviceTimeUp);
                disp(['CPU ���㣬QRP = ',num2str(QRP),'; QMP = ',num2str(QMP)])
                if(QMP < QRP)
%                     ��ʼǨ��
                    l=0;
                    for l=1:3
                        for ��% L��ÿһ��������r��VNF�Ľڵ�v
                            if l=0
                               ��            %r����v�е�VNF�����һ����Wv 
                               Sv=0         %Sv����
                               (Wv,Sv)=SettleInServer       %����SettleInServer����
                            else
                               (Wv,Sv)=SettleInSwitch       %����SettleInSwitch����
                            if size(Sv)==number(VNFs of r)
                                return true
                            else if l==3
                                    ��   %�ع���ִ��ǰ��״̬
                                    return false
                            else %�ϴ��ȴ������ѽ��㼯
                                v'=v�ĸ��ڵ�
                                Wv'+= Wv
                                Sv'+=Sv
                            l=l+1
                  return true














                    disp('ѡ��Ǩ��')
%                     migFlag,migPMNo
                else
%                     ����QRP
                    disp('ѡ������')
%                     CPUResource(PMNum) = 0;
%                     CPUResource(PMNum) - NFVdeltaCPUNum;
                    newCPUNum_vec = oldCPUNum_vec;
                    newCPUNum_vec(NFVNo) = newCPUNum_vec(NFVNo) + CPUResource(PMNum);
                    serviceChainCell{row, 3} = newCPUNum_vec;
                    CPUResource(PMNum) = 0;
                    totalPenalty = totalPenalty + QRP;
                end
