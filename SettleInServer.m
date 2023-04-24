function [Wv, Sv] = SettleInServer(memory, cpu,Wv, Sv, cpu_limit, memory_limit)
    % 计算Sv中已使用的VM的CPU和内存资源总量
    used_cpu_in_Sv = sum(cpu(Sv));
    used_memory_in_Sv = sum(memory(Sv));
    
    % 将背包容量限制为cpu_limit减去Sv中已使用的CPU资源
    cpu = cpu_limit - used_cpu_in_Sv;
    
    % 使用背包问题解决方案找到最佳VM迁移方案
    [max_value, chosen_items] = knapsack_dp(Wv, memory, cpu);
    
    加memory限制
   
    % 更新Wv和Sv数组,完成第一次迁移
    Sv = [Sv, chosen_items];
    Wv(chosen_items) = [];


 

    b = GetUpstreamBandwidth(Sv, bandwidths);%可以直接sum
    while b > bandwidth_limit && numel(Sv) > 0
      %遍历选取 b0[VM] - bi[VM]最大的VM，迁移返回，直至满足带宽需求
       这里要改
       [~, idx] = max(bandwidths(Wv) - bandwidths(Sv));
        VM = Sv(idx);
        
        % 更新 Wv和 Sv
       Sv(chosen_items)= [];
       Wv = [Wv, chosen_items];
        
        % update bandwidth
        b = GetUpstreamBandwidth(Sv, bandwidths);
    end
end


