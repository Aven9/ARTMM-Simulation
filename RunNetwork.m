function NodeMetrix=RunNetwork(NodeMetrix,t)
   PSpd=NodeMetrix.ProduceSpd;
   if mod(t,PSpd)==0
       NodeMetrix.data(6,:)=NodeMetrix.data(6,:)+1;
   end
   
   CSpd=NodeMetrix.ConSpd;
   if mod(t,CSpd)==0
        NodeMetrix=SetCon(NodeMetrix);
   end
   
   NodeMetrix=Sendpacket(NodeMetrix,mod(t,NodeMetrix.update_timeperiod));

end

function NodeMetrix=SetCon(NodeMetrix)
    ConState=NodeMetrix.ConState;
    ConState=ConState+getPLPE();
    ConState=ConState.*NodeMetrix.Neighbor;
    NodeMetrix.ConState=ConState;
end
function P=getPLPE()
    P=1;
end

function NodeMetrix=Sendpacket(NodeMetrix,t)
    SSpd=NodeMetrix.SendSpd;
    pnum=NodeMetrix.nodenum;
   
    NH=NodeMetrix.data(4,:);
    Energy=NodeMetrix.data(5,:);
    SL=NodeMetrix.data(6,:);
   
    TSQ=NodeMetrix.cur_timeWindow.TransSeq;
    Vd=NodeMetrix.cur_timeWindow.Vd;
    
    packet=min(SL,SSpd);
    n_use=NodeMetrix.cur_timeWindow.n_use;
    n_use_cur=zeros(pnum,pnum);
    for pt=1:max(packet)
        for i=1:length(packet)
            if NH(i)~=-1 &&packet(i)~=0
                JP=JudgePacket(packet(i));
                TSQ_sq=find(TSQ(i,NH(i),:)==-1);
                TSQ(i,NH(i),TSQ_sq(1))=JP;
                n_use_cur(i,NH(i))=JP;
            end
        end
        Vd_cur=n_use_cur.*normrnd(0,1,size(n_use_cur));
        n_use=n_use+n_use_cur;
        Vd=(Vd.*(n_use-1)+Vd_cur)./n_use;
    end
    NodeMetrix.cur_timeWindow.n_use=n_use;
    NodeMetrix.cur_timeWindow.Vd=Vd;
    NodeMetrix.cur_timeWindow.TransSeq=TSQ;
    
    
    Energy=Energy-packet;
    NodeMetrix.cur_timeWindow.pene=NodeMetrix.cur_timeWindow.pene+packet;
    for i=1:pnum
        if SL(i)>0 && NH(i)~=-1
            SL(NH(i))=SL(NH(i))+packet(i);
        end
    end
    SL=SL-packet;
%     packet=min(Pre_SL,SSpd);
%     Energy=Energy-packet;
%     SL=SL+packet(Pre_SL(NH));
%     SL=SL-packet;

    NodeMetrix.data(5,:)=Energy;
    NodeMetrix.data(6,:)=SL;
end

function JP=JudgePacket(packet)
    if packet<=0
        JP=0;
    else
%         error rate:Is the packet lost?
        JP=1;
    end
end


