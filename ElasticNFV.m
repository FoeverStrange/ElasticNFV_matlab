clear;
close all
coreSwitchNum = 1;
aggregationSwitchNum = 2;
ToRSwitchNum = 4;
PMNum = 16;

% PM����
PMvCPUNum = 12;
PMmemory = 32 * 10^9;    %��λByte
PMbandWidth = 1*10^9;    %��λbps

% ÿ�����������������ڰ�ָ���ֲ�ѡ��ƽ��Ϊ36�롣
serviceAvgLifeTime = 36;
% Ϊ����DMR����Ķ����ԣ�����ʹ������������Ĳ������̣���Щ���̲��ϵ�ѡ����������Ա��Գ˷���ʽ�����/����С��ģ��
% ���磬����(1)������չ������(2)������չvCPU (fc��Ӧ��ǰ�����еĦ�);
% ����(3)��(4)ͨ������fm (fm��Ӧ�����ǵ���ʽ�����еĦ�)�Ŵ����С�ڴ��С��(5)+(6)ͨ������fb�Ŵ����С����(fb��Ӧ��ǰ�����еĦ�)��
fc = 1.5;
fm = 1.5;
fb = 1.5;

% ϵͳ����
% ϵͳĿǰ������Դ
CPUResource = ones(1, PMNum)*PMvCPUNum;        % ����CPU��Դ
MemoryResource = ones(1, PMNum) * PMmemory;    % ���ô洢��Դ
BandwidthResource = ones(PMNum,PMNum) * PMbandWidth; % ����bandwidth
% ҵ����Ԫ��
serviceChainNum = randi([10 100], 1, 1);      %ҵ��������
serviceChainCell = cell(1,7);
% 1��NFV������2����������ЩPM���ˣ�3��NFV��Ҫ��CPU����4����Ҫ��Mem����5��NFV���������6��ҵ���������ڣ�7��ҵ������ʼ���
count = 0;
for i = 1:serviceChainNum
    count = count + 1;
    NFVNum = randi([2 5]);
    
   
    NFV_PMs_vec = randi([1 PMNum]) * ones(1,NFVNum);   
    
    
    CPU_Num = randi([NFVNum ceil(0.5 * PMvCPUNum)]);    %��ҪCPU����
    r = randperm(CPU_Num-1, NFVNum-1);
    r = sort(r);
    % ÿ��NFV��Ҫ����CPUs
    NFV_CPUs_vec = diff([0 r CPU_Num]);
    
%     ÿ��NFV��Ҫ�ڴ�
    Mem_Sum = randi([NFVNum*100, ceil(0.25 * PMmemory)]);    %��ҪMem����
    r2 = randperm(Mem_Sum-1, NFVNum-1);
    r2 = sort(r2);
    % ÿ��NFV��Ҫ����Mem
    NFV_Mem_vec = diff([0 r2 Mem_Sum]);
    
%   NFV֮���������
    NFV_Bnd_vec = randi([1000 ceil(PMbandWidth/4)],1,NFVNum-1);
    
%     ҵ����������
    serviceLifeTime = exprnd(serviceAvgLifeTime);
    PM_No = NFV_PMs_vec(1);
    if(CPUResource(PM_No) < CPU_Num || MemoryResource(PM_No) < Mem_Sum)
%         ��ʼ��ʧ�ܣ���Դ����
        count = count -1;
       continue 
    else
        CPUResource(PM_No) = CPUResource(PM_No) - CPU_Num;
        MemoryResource(PM_No) = MemoryResource(PM_No) - Mem_Sum;
        serviceChainCell{count, 1} = NFVNum;           %NFV����
        serviceChainCell{count,2} = NFV_PMs_vec;       %NFV�����ļ���PM���ˣ���ʼ������һ��PM
        serviceChainCell{count,3} = NFV_CPUs_vec;
        serviceChainCell{count,4} = NFV_Mem_vec;
        serviceChainCell{count,5} = NFV_Bnd_vec;
        serviceChainCell{count,6} = serviceLifeTime;
        serviceChainCell{count,7} = count;
    end
end
serviceChainNum = count;
% ����possion���̵������������
T = 100;
% �µ�DMR������ݦ� = 0.36�Ĳ��ɹ��̵��
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

% ��Ҫ�������TimeStamps��������
% ����������ƴ�ӳ�һ��������
concatenated_array = [CPUupTimeStamps_vec;CPUdwTimeStamps_vec;MemupTimeStamps_vec;MemdwTimeStamps_vec;BndupTimeStamps_vec;BnddwTimeStamps_vec];
% ��ƴ�Ӻ�������������
% sorted_TimeStamps_vec = sort(concatenated_array);
% �Ե�һ�е�ֵ�������򣬲���������������
[~, idx] = sort(concatenated_array(:, 1));
% �����������������ž���
sorted_TimeStamps_vec = concatenated_array(idx, :);
timestampsNum = length(sorted_TimeStamps_vec);
for i = 1:timestampsNum
    serviceChainNo = randi([1,serviceChainNum]);
    sorted_TimeStamps_vec(i,3) = serviceChainNo;   %�����ǵڼ���ҵ����
    NFVNum = serviceChainCell{serviceChainNo,1};
    NFVNo = randi([1,NFVNum]);
    sorted_TimeStamps_vec(i,4) = NFVNo;   %�����ǵڼ���NFV
end
% sorted_TimeStamps_vec��1��ʱ�����2���������ࣻ3���ڼ���ҵ������4���ڼ���NFV

for stamp = 1:timestampsNum
    time = sorted_TimeStamps_vec(stamp,1);     %�ʱ�����ʱ��
%     ϵͳ��Դ�ͷź���������Ƿ����������ڵ�ͷ��ҵ��
    [CPUResource,MemoryResource,BandwidthResource,serviceChainCell] = sysUpdate(serviceChainCell, time, CPUResource,MemoryResource,BandwidthResource);
%    ����ҵ��������ʵ���ʱ�
    elasticNo = sorted_TimeStamps_vec(stamp,2); %��������
    % ���磬����(1)������չ������(2)������չvCPU (fc��Ӧ��ǰ�����еĦ�);
% ����(3)��(4)ͨ������fm (fm��Ӧ�����ǵ���ʽ�����еĦ�)�Ŵ����С�ڴ��С��(5)+(6)ͨ������fb�Ŵ����С����(fb��Ӧ��ǰ�����еĦ�)��
    chainNo = sorted_TimeStamps_vec(stamp,3); %�ڼ���ҵ����(��ʼ
    [rows,cols] = find(cellfun(@(x) isequal(x, chainNo), serviceChainCell));
%     ��Ҫȷ��cols�ڵ�����
    idx = find(cols == 7);
    row = rows(idx);
    if(isempty(row))
       continue
    end
    NFVNo = sorted_TimeStamps_vec(stamp,4); %�ڼ���NFV
    if(elasticNo == 2 || elasticNo == 4 ||elasticNo == 6)
%        ��Сֱ���ͷ���Դ
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
                        %��������һ��NFV/�������NFV��ͬһ��PM�����ͷ�
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
%    �ж��Ƿ��г�ͻ,��鵱ǰ��Դ������Ա�����
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
                disp('CPU ����')
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
                    disp('Mem ����')
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
                        %��������һ��NFV/�������NFV��ͬһ��PM��������
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
                            disp('bnd ����')
                        end
                    else
                        continue
                    end
                    
                end
            end
        end
    end
% ����TPMM��������gzj
%     TPMM();
% �ռ�������Ϣ��cost���


end
stamp

function [CPUResource,MemoryResource,BandwidthResource,serviceChainCell] = sysUpdate(serviceChainCell,timeNow,CPUResource,MemoryResource,BandwidthResource)
%     ͳ��ҵ����Ԫ�飬��������PM����Դ���������cpu��Դ��mem��Դ��bnd��Դ
    [serviceChainNum, ~] = size(serviceChainCell);
    for i = serviceChainNum:-1:1
        if(serviceChainCell{i,6}<timeNow)
%             ��Դ�ͷ�
            % ҵ���� 1��NFV������2����������ЩPM���ˣ�3��NFV��Ҫ��CPU����4����Ҫ��Mem����5��NFV���������6��ҵ����������
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
% δ��������������ɵ���ʧ
QRP = RefuseNum/RequestNum;

end

function QMP = QMPComputing(oldServiceTime,NFVData,CommuSpeed,serviceLifetime,serviceTimeUp)
% Ǩ����ʧ������Ǩ�Ƶ����ݴ���ʱ�Ӻ�ҵ��ʱ���������
% QMP = 0;
DataTransformTime = NFVData / CommuSpeed;
TransformTimeRatio = DataTransformTime/serviceLifetime;
serviceTimeUpRatio = serviceTimeUp / oldServiceTime;
QMP = TransformTimeRatio + serviceTimeUpRatio;
end

function [timestamps_vec] = NFVElasticRequest_Possion(lambda,T)
% lambda = 0.36; % ָ�����ɹ��̵�ǿ�Ȳ���
% T = 100; % ģ���ʱ�䳤��
N = poissrnd(lambda*T); % ���ɷ��ϲ��ɷֲ�������¼�����

% ���ɷ���ָ���ֲ�������¼����ʱ��
interarrival_times = exprnd(1/lambda, [N, 1]);

% ����ÿ������¼���ʱ���
timestamps_vec = cumsum(interarrival_times);

end


function [a, b] = TPMM()
a = 0;
b = 0;

end
