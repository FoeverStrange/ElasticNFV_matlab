function [Wv,Sv] = SettleInServer(v,Wv,Sv,l)

if l-1 = 0
    for ÿһ���ײ�ڵ�v���ӽڵ�v' do
        [Wv,Sv] = SettleInServer(v' , Wv , Sv ) ;
        if size(Wv)==0
            break
else
    for ÿһ���ײ�ڵ�v���ӽڵ�v' do
        [Wv,Sv] = SettleInSwitch(v' , Wv , Sv , l-1 );
        if size(Wv)==0
            break
b = GetUpstreamBandwidth(Sv );
if b������ǰ����
    for Sv�е�ÿһ��VM
        Sv -= VM
        Wv += VM
return ( Wv , Sv )