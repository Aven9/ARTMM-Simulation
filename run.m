clear;
clc;
t=0;
pnum=50;
update_timeperiod=10;
NodeMetrix=Init_Node_Metrix(pnum);

for t=0:50
    if mod(t,update_timeperiod)==0
        NodeMetrix=UpdateInfo(NodeMetrix,t);
        
    end
    NodeMetrix=RunNetwork(NodeMetrix,t);
end