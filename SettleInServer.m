function [Wv,Sv] = SettleInServer(v,Wv,Sv)
(Wv,Sv)=knapsack(v,Wv,Sv); %�������⣬CPU��volume���ڴ���memory

b=GetUpstreamBandwidth(Sv); %��ȡSv�����д���

while b������ǰ���� and size(Sv)>0 do
    ?;%����ѡȡ b0[VM] - bi[VM]����VM
    Sv -= VM;
    Wv += VM;
    b = GetUpstreamBandwidth(Sv );
return (Wv,Sv)



