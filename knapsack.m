function [Wv,Sv] = knapsack(v, Wv, Sv)  %重量、价值、容量
n = length(v);
dp = zeros(n+1, Sv+1);
for i = 1:n
    for j = 1:Sv
        if v(i) <= j
            dp(i+1,j) = max(dp(i,j-v(i))+Wv(i), dp(i,j));
        else
            dp(i+1,j) = dp(i,j);
        end
    end
end
[Wv,Sv] = dp(n+1,Sv+1);
end