clear;
close all
coreSwitchNum = 1;
aggregationSwitchNum = 2;
ToRSwitchNum = 4;
PMNum = 16;

% PM配置
PMvCPUNum = 12;
PMmemory = 32 * 10^9;    %单位Byte
PMbandWidth = 1*10^9;    %单位bps

% 每个服务链的生命周期按指数分布选择，平均为60秒。
serviceAvgLifeTime = 60;
% 为增加DMR请求的多样性，我们使用了六个额外的泊松流程，这些流程不断地选择服务链，以便以乘法方式扩大和/或缩小规模。
% 例如，进程(1)向上扩展，进程(2)向下扩展vCPU (fc对应于前几节中的α);
% 过程(3)和(4)通过因子fm (fm对应于我们的形式部分中的β)放大或缩小内存大小，(5)+(6)通过因子fb放大或缩小带宽(fb对应于前部分中的γ)。
fc = 1.5;
fm = 1.5;
fb = 1.5;

% 系统配置
DEFINE_SERVICETIME = 1;
DEFINE_NFVDATA = 10 * 10^6;
DEFINE_COMMUSPEED = 2 * 10^6;
DEFINE_SERVICETIME_UP = 0.1;
% 系统目前可用资源
CPUResource = ones(1, PMNum)*PMvCPUNum;        % 可用CPU资源
MemoryResource = ones(1, PMNum) * PMmemory;    % 可用存储资源
BandwidthResource = ones(PMNum,PMNum) * PMbandWidth; % 可用bandwidth
% 业务链元组
serviceChainNum = randi([50 100], 1, 1);      %业务链数量
serviceChainCell = cell(1,7);
% 1：NFV数量；2：部署在哪些PM上了；3：NFV需要的CPU数；4：需要的Mem数；5：NFV间带宽需求；6：业务生命周期；7：业务链初始编号
count = 0;
for i = 1:serviceChainNum
    count = count + 1;
    NFVNum = randi([2 5]);
    
   
    NFV_PMs_vec = randi([1 PMNum]) * ones(1,NFVNum);   
    
    
    CPU_Num = randi([NFVNum ceil(0.5 * PMvCPUNum)]);    %需要CPU总数
    r = randperm(CPU_Num-1, NFVNum-1);
    r = sort(r);
    % 每个NFV需要几个CPUs
    NFV_CPUs_vec = diff([0 r CPU_Num]);
    
%     每个NFV需要内存
    Mem_Sum = randi([ceil(PMmemory/4/2), ceil(PMmemory/2)]);    %需要Mem总数
    r2 = randperm(Mem_Sum-1, NFVNum-1);
    r2 = sort(r2);
    % 每个NFV需要多少Mem
    NFV_Mem_vec = diff([0 r2 Mem_Sum]);
    
%   NFV之间带宽需求
    NFV_Bnd_vec = randi([ceil(PMbandWidth/4) ceil(PMbandWidth/2)],1,NFVNum-1);
    
%     业务生命周期
    serviceLifeTime = exprnd(serviceAvgLifeTime);
    PM_No = NFV_PMs_vec(1);
    if(CPUResource(PM_No) < CPU_Num || MemoryResource(PM_No) < Mem_Sum)
%         初始化失败，资源不足
        count = count -1;
       continue 
    else
        CPUResource(PM_No) = CPUResource(PM_No) - CPU_Num;
        MemoryResource(PM_No) = MemoryResource(PM_No) - Mem_Sum;
        serviceChainCell{count, 1} = NFVNum;           %NFV数量
        serviceChainCell{count,2} = NFV_PMs_vec;       %NFV部署到哪几个PM上了（初始化都在一个PM
        serviceChainCell{count,3} = NFV_CPUs_vec;
        serviceChainCell{count,4} = NFV_Mem_vec;
        serviceChainCell{count,5} = NFV_Bnd_vec;
        serviceChainCell{count,6} = serviceLifeTime;
        serviceChainCell{count,7} = count;
    end
end
serviceChainNum = count;
% 按照possion过程的新增任务迭代
T = 100;
% 新的DMR请求根据λ = 0.36的泊松过程到达。
PoissonLambda = 0.36;
[CPUupTimeStamps_vec] = NFVElasticRequest_Possion(PoissonLambda,T);
CPUupTimeStamps_vec = [CPUupTimeStamps_vec, ones(length(CPUupTimeStamps_vec),1)];
[CPUdwTimeStamps_vec] = NFVElasticRequest_Possion(PoissonLambda,T);
CPUdwTimeStamps_vec = [CPUdwTimeStamps_vec, ones(length(CPUdwTimeStamps_vec),1) * 2];
[MemupTimeStamps_vec] = NFVElasticRequest_Possion(PoissonLambda,T);
MemupTimeStamps_vec = [MemupTimeStamps_vec, ones(length(MemupTimeStamps_vec),1)*3];
[MemdwTimeStamps_vec] = NFVElasticRequest_Possion(PoissonLambda,T);
MemdwTimeStamps_vec = [MemdwTimeStamps_vec, ones(length(MemdwTimeStamps_vec),1)*4];
[BndupTimeStamps_vec] = NFVElasticRequest_Possion(PoissonLambda,T);
BndupTimeStamps_vec = [BndupTimeStamps_vec, ones(length(BndupTimeStamps_vec),1)*5];
[BnddwTimeStamps_vec] = NFVElasticRequest_Possion(PoissonLambda,T);
BnddwTimeStamps_vec = [BnddwTimeStamps_vec, ones(length(BnddwTimeStamps_vec),1)*6];

% 需要组合六个TimeStamps，并排序
% 将六个数组拼接成一个大数组
concatenated_array = [CPUupTimeStamps_vec;CPUdwTimeStamps_vec;MemupTimeStamps_vec;MemdwTimeStamps_vec;BndupTimeStamps_vec;BnddwTimeStamps_vec];
% 对拼接后的数组进行排序
% sorted_TimeStamps_vec = sort(concatenated_array);
% 对第一列的值进行排序，并返回排序后的索引
[~, idx] = sort(concatenated_array(:, 1));
% 根据排序后的索引重排矩阵
sorted_TimeStamps_vec = concatenated_array(idx, :);
timestampsNum = length(sorted_TimeStamps_vec);
for i = 1:timestampsNum
    serviceChainNo = randi([1,serviceChainNum]);
    sorted_TimeStamps_vec(i,3) = serviceChainNo;   %表明是第几个业务链
    NFVNum = serviceChainCell{serviceChainNo,1};
    NFVNo = randi([1,NFVNum]);
    sorted_TimeStamps_vec(i,4) = NFVNo;   %表明是第几个NFV
end
% sorted_TimeStamps_vec：1、时间戳；2、弹性种类；3、第几个业务链；4、第几个NFV
totalPenalty = 0;   %统计总损失
for stamp = 1:timestampsNum
    time = sorted_TimeStamps_vec(stamp,1);     %适变需求时刻
%     系统资源释放函数，检查是否有生命周期到头的业务
    [CPUResource,MemoryResource,BandwidthResource,serviceChainCell] = sysUpdate(serviceChainCell, time, CPUResource,MemoryResource,BandwidthResource);
%    根据业务弹性需求实现适变
    elasticNo = sorted_TimeStamps_vec(stamp,2); %弹性种类
    % 例如，进程(1)向上扩展，进程(2)向下扩展vCPU (fc对应于前几节中的α);
% 过程(3)和(4)通过因子fm (fm对应于我们的形式部分中的β)放大或缩小内存大小，(5)+(6)通过因子fb放大或缩小带宽(fb对应于前部分中的γ)。
    chainNo = sorted_TimeStamps_vec(stamp,3); %第几个业务链(初始
    [rows,cols] = find(cellfun(@(x) isequal(x, chainNo), serviceChainCell));
%     需要确定cols在第七列
    idx = find(cols == 7);
    row = rows(idx);
    if(isempty(row))
       continue
    end
    NFVNo = sorted_TimeStamps_vec(stamp,4); %第几个NFV
    if(elasticNo == 2 || elasticNo == 4 ||elasticNo == 6)
%        缩小直接释放资源
        if(elasticNo == 2)
            PM_vec = serviceChainCell{row,2};
            PMNum = PM_vec(NFVNo);
            oldCPUNum_vec = serviceChainCell{row, 3};
            NFVoldCPUNum = oldCPUNum_vec(NFVNo);
            NFVnewCPUNum = ceil(NFVoldCPUNum / fc);
            NFVdeltaCPUNum = NFVoldCPUNum - NFVnewCPUNum;
            CPUResource(PMNum) = CPUResource(PMNum) + NFVdeltaCPUNum;
            newCPUNum_vec = oldCPUNum_vec;
            newCPUNum_vec(NFVNo) = NFVnewCPUNum;
            serviceChainCell{row, 3} = newCPUNum_vec;
        else
            if(elasticNo == 4)
                PM_vec = serviceChainCell{row,2};
                PMNum = PM_vec(NFVNo);
                oldMemNum_vec = serviceChainCell{row, 4};
                NFVoldMemNum = oldMemNum_vec(NFVNo);
                NFVnewMemNum = ceil(NFVoldMemNum / fm);
                NFVdeltaMemNum = NFVoldMemNum - NFVnewMemNum;
                MemoryResource(PMNum) = MemoryResource(PMNum) + NFVdeltaMemNum;
                newMemNum_vec = oldMemNum_vec;
                newMemNum_vec(NFVNo) = NFVnewMemNum;
                serviceChainCell{row,4} = newMemNum_vec;
            else
                if(elasticNo == 6)
                    PM_vec = serviceChainCell{row,2};
                    NFVNum = serviceChainCell{row,1};
                    if(NFVNum > NFVNo)
                        PMNum_from = PM_vec(NFVNo);
                        PMNum_to = PM_vec(NFVNo+1);
                        if(PMNum_from == PMNum_to)
                           continue 
                        end
                        %如果是最后一个NFV/如果两个NFV在同一个PM，则不释放
                        oldbndNum_vec = serviceChainCell{row, 5};
                        NFVoldbndNum = oldbndNum_vec(NFVNo);
                        NFVnewbndNum = ceil(NFVoldbndNum / fb);
                        NFVdeltabndNum = NFVoldbndNum - NFVnewbndNum;
                        BandwidthResource(PMNum_from,PMNum_to) = BandwidthResource(PMNum_from,PMNum_to) + NFVdeltabndNum;
                        newbndNum_vec = oldbndNum_vec;
                        newbndNum_vec(NFVNo) = NFVnewbndNum;
                        serviceChainCell{row,5} = newbndNum_vec;
                    else
                        continue
                    end
                    
                end
            end
        end
        continue
    end
%    判断是否有冲突,检查当前资源情况，对比需求
    if(elasticNo == 1 || elasticNo == 3 ||elasticNo == 5)
        if(elasticNo == 1)
            PM_vec = serviceChainCell{row,2};
            PMNum = PM_vec(NFVNo);
            oldCPUNum_vec = serviceChainCell{row, 3};
            NFVoldCPUNum = oldCPUNum_vec(NFVNo);
            NFVnewCPUNum = ceil(NFVoldCPUNum * fc);
            NFVdeltaCPUNum = NFVnewCPUNum - NFVoldCPUNum;
            if(CPUResource(PMNum) >= NFVdeltaCPUNum)
                CPUResource(PMNum) = CPUResource(PMNum) - NFVdeltaCPUNum;
                newCPUNum_vec = oldCPUNum_vec;
                newCPUNum_vec(NFVNo) = NFVnewCPUNum;
                serviceChainCell{row, 3} = newCPUNum_vec;
            else
%                 CPU不足
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
                    disp('选择迁移')
                    
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
                
            end
            
        else
            if(elasticNo == 3)
                PM_vec = serviceChainCell{row,2};
                PMNum = PM_vec(NFVNo);
                oldMemNum_vec = serviceChainCell{row, 4};
                NFVoldMemNum = oldMemNum_vec(NFVNo);
                NFVnewMemNum = ceil(NFVoldMemNum * fm);
                NFVdeltaMemNum = NFVnewMemNum - NFVoldMemNum;
                if(MemoryResource(PMNum) >= NFVdeltaMemNum)
                    MemoryResource(PMNum) = MemoryResource(PMNum) - NFVdeltaMemNum;
                    newMemNum_vec = oldMemNum_vec;
                    newMemNum_vec(NFVNo) = NFVnewMemNum;
                    serviceChainCell{row,4} = newMemNum_vec;
                else
%                     disp('Mem 不足')
                    RefuseNum = NFVdeltaMemNum - MemoryResource(PMNum);
                    RequestNum = NFVnewMemNum;
                    QRP = QRPComputing(RequestNum, RefuseNum);
                    oldServiceTime = DEFINE_SERVICETIME;
                    NFVData = DEFINE_NFVDATA;
                    CommuSpeed = DEFINE_COMMUSPEED;
                    serviceLifetime = serviceChainCell{row, 6};
                    serviceTimeUp = DEFINE_SERVICETIME_UP;
                    QMP = QMPComputing(oldServiceTime,NFVData,CommuSpeed,serviceLifetime,serviceTimeUp);
                    disp(['Mem 不足，QRP = ',num2str(QRP),'; QMP = ',num2str(QMP)])
                    if(QMP < QRP)
%                       开始迁移
                        disp('选择迁移')
                    
                    else
%                     忍受QRP
                        disp('选择忍受')
%                     CPUResource(PMNum) = 0;
%                     CPUResource(PMNum) - NFVdeltaCPUNum;
                        newMemNum_vec = oldMemNum_vec;
                        newMemNum_vec(NFVNo) = newMemNum_vec(NFVNo) + MemoryResource(PMNum);
                        serviceChainCell{row, 3} = newMemNum_vec;
                        MemoryResource(PMNum) = 0;
                        totalPenalty = totalPenalty + QRP;
                    end
                end
                
            else
                if(elasticNo == 5)
                    PM_vec = serviceChainCell{row,2};
                    NFVNum = serviceChainCell{row,1};
                    if(NFVNum > NFVNo)
                        PMNum_from = PM_vec(NFVNo);
                        PMNum_to = PM_vec(NFVNo+1);
                        if(PMNum_from == PMNum_to)
                           continue 
                        end
                        %如果是最后一个NFV/如果两个NFV在同一个PM，则不扩张
                        oldbndNum_vec = serviceChainCell{row, 6};
                        NFVoldbndNum = oldbndNum_vec(NFVNo);
                        NFVnewbndNum = ceil(NFVoldbndNum * fb);
                        NFVdeltabndNum = NFVnewbndNum - NFVoldbndNum;
                        if(BandwidthResource(PMNum_from,PMNum_to) >= NFVdeltabndNum)
                            BandwidthResource(PMNum_from,PMNum_to) = BandwidthResource(PMNum_from,PMNum_to) - NFVdeltabndNum;
                            newbndNum_vec = oldbndNum_vec;
                            newbndNum_vec(NFVNo) = NFVnewbndNum;
                            serviceChainCell{row,5} = newbndNum_vec;
                        else
%                             disp('bnd 不足')
                            RefuseNum = NFVdeltabndNum - BandwidthResource(PMNum_from,PMNum_to);
                            RequestNum = NFVnewbndNum;
                            QRP = QRPComputing(RequestNum, RefuseNum);
                            oldServiceTime = DEFINE_SERVICETIME;
                            NFVData = DEFINE_NFVDATA;
                            CommuSpeed = DEFINE_COMMUSPEED;
                            serviceLifetime = serviceChainCell{row, 6};
                            serviceTimeUp = DEFINE_SERVICETIME_UP;
                            QMP = QMPComputing(oldServiceTime,NFVData,CommuSpeed,serviceLifetime,serviceTimeUp);
                            disp(['Bnd 不足，QRP = ',num2str(QRP),'; QMP = ',num2str(QMP)])
                            if(QMP < QRP)
%                       开始迁移
                                disp('选择迁移')
                    
                            else
%                     忍受QRP
                                disp('选择忍受')
%                     CPUResource(PMNum) = 0;
%                     CPUResource(PMNum) - NFVdeltaCPUNum;
                                newbndNum_vec = oldbndNum_vec;
                                newbndNum_vec(NFVNo) = newbndNum_vec(NFVNo) + BandwidthResource(PMNum_from,PMNum_to);
                                serviceChainCell{row, 3} = newbndNum_vec;
                                BandwidthResource(PMNum_from,PMNum_to) = 0;
                                totalPenalty = totalPenalty + QRP;
                            end
                    
                        end
                    else
                        continue
                    end
                    
                end
            end
        end
    end
% 调用TPMM函数——gzj
%     TPMM();
% 收集性能信息，cost情况


end
disp(['End Main, stampSum = ', num2str(stamp)])

function [CPUResource,MemoryResource,BandwidthResource,serviceChainCell] = sysUpdate(serviceChainCell,timeNow,CPUResource,MemoryResource,BandwidthResource)
%     查询是否有生命周期结束的业务，释放他们的资源
%     统计业务链元组，更新所有PM的资源情况，包括cpu资源、mem资源和bnd资源
    [serviceChainNum, ~] = size(serviceChainCell);
    for i = serviceChainNum:-1:1
        if(serviceChainCell{i,6}<timeNow)
%             资源释放
            % 业务链 1：NFV数量；2：部署在哪些PM上了；3：NFV需要的CPU数；4：需要的Mem数；5：NFV间带宽需求；6：业务生命周期
            NFV_Num = serviceChainCell{i,1};
            PM_vec = serviceChainCell{i,2};
            PM_CPU_vec = serviceChainCell{i,3};
            PM_Mem_vec = serviceChainCell{i,4};
            PM_bnd_vec = serviceChainCell{i,5};
            for j = 1:NFV_Num-1
                from = PM_vec(j);
                to = PM_vec(j+1);
               if(from ~= to)
                   BandwidthResource(from,to) = BandwidthResource(from,to) + PM_bnd_vec(j);
               end
               CPUResource(from) = CPUResource(from) + PM_CPU_vec(j);
               MemoryResource(from) = MemoryResource(from) + PM_Mem_vec(j);
            end
            to = PM_vec(NFV_Num);
            CPUResource(to) = CPUResource(to) + PM_CPU_vec(NFV_Num);
            MemoryResource(to) = MemoryResource(to) + PM_Mem_vec(NFV_Num);
           serviceChainCell(i,:) = [];
        end
    end
    
end

function QRP = QRPComputing(RequestNum, RefuseNum)
% 未能满足需求所造成的损失
QRP = RefuseNum/RequestNum;

end

function QMP = QMPComputing(oldServiceTime,NFVData,CommuSpeed,serviceLifetime,serviceTimeUp)
% 迁移损失；包括迁移的数据传输时延和业务时延增加情况
% QMP = 0;
DataTransformTime = NFVData / CommuSpeed;
TransformTimeRatio = DataTransformTime/serviceLifetime;
serviceTimeUpRatio = serviceTimeUp / oldServiceTime;
QMP = TransformTimeRatio + serviceTimeUpRatio;
end

function [timestamps_vec] = NFVElasticRequest_Possion(lambda,T)
% lambda = 0.36; % 指定泊松过程的强度参数
% T = 100; % 模拟的时间长度
N = poissrnd(lambda*T); % 生成符合泊松分布的随机事件数量

% 生成符合指数分布的随机事件间隔时间
interarrival_times = exprnd(1/lambda, [N, 1]);

% 计算每个随机事件的时间戳
timestamps_vec = cumsum(interarrival_times);

end


function [a, b] = TPMM()
a = 0;
b = 0;

end
