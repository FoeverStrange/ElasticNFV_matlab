function [new_ServiceChain_vec] = migrate_NFVs_knapsack(PM1, PM2, MemoryResource, serviceChainCell)

        PM1 = PMNO ;
        PM2 = best_PM ;
        n = NFVNum;%PM1中的NFV数目
        
        capacity = MemoryResource(PM2); % Memory容量作为背包容量
        values = serviceChainCell{row, 3}; %从PM1迁移至PM2的NFV CPU作为背包价值
        weights = serviceChainCell{row, 4}; % 从PM1迁移至PM2的NFV Memory作为背包重量

        % 使用动态规划求解 0-1 背包问题
        dp = zeros(n + 1, capacity + 1);
        for i = 1:n
            for w = 1:capacity
                if weights(i) <= w
                    dp(i + 1, w + 1) = max(dp(i, w + 1), dp(i, w - weights(i) + 1) + values(i));
                else
                    dp(i + 1, w + 1) = dp(i, w + 1);
                end
            end
        end

        % 回溯得到选择的 NFV
        chosen = false(1, n);
        w = capacity;
        for i = n:-1:1
            if dp(i + 1, w + 1) ~= dp(i, w + 1)
                chosen(i) = true;
                w = w - weights(i);
            end
        end

        % 迁移所选 NFV 到 PM2
        serviceChainCell{row, 2} = chosen * (PM2 - PM1) + serviceChainCell{row, 2};


       % 检查PM2的带宽是否超过了其总容量
       PM2Bandwidth = chosen * [serviceChainCell{row, 5} 0] + chosen * [0 serviceChainCell{row, 5}];

    while sum(PM2Bandwidth) > BandwidthResource(PM2) % PM2的Bandwidth容量
        
        % 找到带宽最大的NFV节点
        [~, idx] = max(PM2Bandwidth);
        
        % 将这个节点迁移回PM1
       newPM_vec = serviceChainCell{row, 2};                        
       newPM_vec(idx+1) = PM1;
       serviceChainCell{row, 2} = newPM_vec;
       new_ServiceChain_vec = old_ServiceChain_vec;
    end
end