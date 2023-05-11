function [migFlag, new_ServiceChain_vec] = RandChoose_Elastic_topo(old_ServiceChain_vec, CPUResource, MemoryResource, BandwidthResource, NFVNo, NFVnewCPUNum, elasticNo, PMNum, NODE_TOPOLOGY)
    % 初始化输出变量
    migFlag = 0;
    old_ServiceChain_vec = serviceChainCell;
    new_ServiceChain_vec = old_ServiceChain_vec;
    
    
    % 当前NFV所在的PM
    currentPM = PMNo ;
    
    % 获取两跳内的PM
    neighbors_1hop = find(NODE_TOPOLOGY(currentPM, :) > 0);
    neighbors_2hop = [];
    for i = 1:length(neighbors_1hop)
        curr_neighbors = find(NODE_TOPOLOGY(neighbors_1hop(i), :) > 0);
        neighbors_2hop = [neighbors_2hop, curr_neighbors];
    end
    neighbors_2hop = setdiff(neighbors_2hop, [currentPM, neighbors_1hop]);
    all_neighbors = union(neighbors_1hop, neighbors_2hop);

    % 初始化最小代价和最佳PM
    min_cost = Inf;
    best_PM = -1;

    % 遍历一个拓扑中两跳内的PM节点进行迁移
    for attempt = 1:length(all_neighbors)
        % 选择一个两跳内PM
        
        randPM = all_neighbors(attempt);
        
        % 检查资源是否满足条件（需要修改主代码，能够表示每个PM的资源剩余）,至少满足迁移当前发生变化的NFV的资源
        if CPUResource(randPM) >= NFVnewCPUNum && MemoryResource(randPM) >= MemoryResource(NFVNo) && BandwidthResource(randPM) >= (BandwidthResource(NFVNo)+BandwidthResource(NFVNo - 1))
            % 计算迁移代价（节点间距离）
            cost = distance(NODE_TOPOLOGY ,currentPM, randPM);
            
            % 如果当前代价小于最小代价，更新最小代价和最佳PM
            if cost < min_cost
                min_cost = cost;
                best_PM = randPM;
            end
        end
    end

    % 如果找到了最佳PM，执行迁移
    if best_PM ~= -1
        PM_vec(NFVNo)= best_PM;
        serviceChainCell{row,2} = PM_vec;
        new_ServiceChain_vec = old_ServiceChain_vec;
        migFlag = 1;
    end
end
