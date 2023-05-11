function [migFlag, new_ServiceChain_vec] = RandChoose_Elastic_topo(old_ServiceChain_vec, CPUResource, MemoryResource, BandwidthResource, NFVNo, NFVnewCPUNum, elasticNo, PMNum, NODE_TOPOLOGY)
    % ��ʼ���������
    migFlag = 0;
    old_ServiceChain_vec = serviceChainCell;
    new_ServiceChain_vec = old_ServiceChain_vec;
    
    
    % ��ǰNFV���ڵ�PM
    currentPM = PMNo ;
    
    % ��ȡ�����ڵ�PM
    neighbors_1hop = find(NODE_TOPOLOGY(currentPM, :) > 0);
    neighbors_2hop = [];
    for i = 1:length(neighbors_1hop)
        curr_neighbors = find(NODE_TOPOLOGY(neighbors_1hop(i), :) > 0);
        neighbors_2hop = [neighbors_2hop, curr_neighbors];
    end
    neighbors_2hop = setdiff(neighbors_2hop, [currentPM, neighbors_1hop]);
    all_neighbors = union(neighbors_1hop, neighbors_2hop);

    % ��ʼ����С���ۺ����PM
    min_cost = Inf;
    best_PM = -1;

    % ����һ�������������ڵ�PM�ڵ����Ǩ��
    for attempt = 1:length(all_neighbors)
        % ѡ��һ��������PM
        
        randPM = all_neighbors(attempt);
        
        % �����Դ�Ƿ�������������Ҫ�޸������룬�ܹ���ʾÿ��PM����Դʣ�ࣩ,��������Ǩ�Ƶ�ǰ�����仯��NFV����Դ
        if CPUResource(randPM) >= NFVnewCPUNum && MemoryResource(randPM) >= MemoryResource(NFVNo) && BandwidthResource(randPM) >= (BandwidthResource(NFVNo)+BandwidthResource(NFVNo - 1))
            % ����Ǩ�ƴ��ۣ��ڵ����룩
            cost = distance(NODE_TOPOLOGY ,currentPM, randPM);
            
            % �����ǰ����С����С���ۣ�������С���ۺ����PM
            if cost < min_cost
                min_cost = cost;
                best_PM = randPM;
            end
        end
    end

    % ����ҵ������PM��ִ��Ǩ��
    if best_PM ~= -1
        PM_vec(NFVNo)= best_PM;
        serviceChainCell{row,2} = PM_vec;
        new_ServiceChain_vec = old_ServiceChain_vec;
        migFlag = 1;
    end
end
