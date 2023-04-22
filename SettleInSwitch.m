function [Wv,Sv] = SettleInServer(v,Wv,Sv,l)

if l-1 = 0
    for 每一个底层节点v的子节点v' do
        [Wv,Sv] = SettleInServer(v' , Wv , Sv ) ;
        if size(Wv)==0
            break
else
    for 每一个底层节点v的子节点v' do
        [Wv,Sv] = SettleInSwitch(v' , Wv , Sv , l-1 );
        if size(Wv)==0
            break
b = GetUpstreamBandwidth(Sv );
if b超出当前限制
    for Sv中的每一个VM
        Sv -= VM
        Wv += VM
return ( Wv , Sv )