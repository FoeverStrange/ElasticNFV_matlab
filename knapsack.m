function [max_value, chosen_items] = knapsack_dp(weights, values, W)
    N = numel(weights);
    dp = zeros(N+1, W+1);
    
    for i = 1:N
        for w = 0:W
            if weights(i) <= w
                dp(i+1, w+1) = max(dp(i, w+1-weights(i)) + values(i), dp(i, w+1));
            else
                dp(i+1, w+1) = dp(i, w+1);
            end
        end
    end
    
    max_value = dp(N+1, W+1);
    chosen_items = [];
    i = N;
    w = W;
    while i > 0
        if dp(i+1, w+1) ~= dp(i, w+1)
            chosen_items = [chosen_items, i];
            w = w - weights(i);
        end
        i = i - 1;
    end
    chosen_items = fliplr(chosen_items);
end
