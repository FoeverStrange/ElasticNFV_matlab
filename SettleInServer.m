function [Wv,Sv] = SettleInServer(v,Wv,Sv)
(Wv,Sv)=knapsack(v,Wv,Sv); %背包问题，CPU是volume，内存是memory

b=GetUpstreamBandwidth(Sv); %获取Sv的上行带宽

while b超出当前限制 and size(Sv)>0 do
    ?;%遍历选取 b0[VM] - bi[VM]最大的VM
    Sv -= VM;
    Wv += VM;
    b = GetUpstreamBandwidth(Sv );
return (Wv,Sv)



