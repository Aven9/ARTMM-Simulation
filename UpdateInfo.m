function NodeMetrix=UpdateInfo(NodeMetrix,t)
      deta=1;  
      [NodeMetrix.data(1,:),NodeMetrix.data(2,:)]=Get_position(NodeMetrix.data(1,:),NodeMetrix.data(2,:),t,deta);
      NodeMetrix.DistToNode=constructW(NodeMetrix);
      NodeMetrix=update_Neighbor(NodeMetrix);
      NodeMetrix=update_Nexthop(NodeMetrix);
      NodeMetrix=update_N_use(NodeMetrix);
      NodeMetrix=update_pene(NodeMetrix);
end

function W=constructW(NodeMetrix)
    fea_a=NodeMetrix.data(1:2,:)';
    bSqrt = 1;
    aa = sum(fea_a.*fea_a,2);
    ab = fea_a*fea_a';

    if issparse(aa)
        aa = full(aa);
    end

    D = bsxfun(@plus,aa,aa') - 2*ab;
    D(D<0) = 0;
    if bSqrt
        D = sqrt(D);
    end
    W = max(D,D');

end

function NodeMetrix=update_Neighbor(NodeMetrix)
%     condist means the max distance of Node direct communication
    Neighbor=NodeMetrix.Neighbor;
    condist=NodeMetrix.condist;
    
    Dist=NodeMetrix.DistToNode;
    Dist(Dist>condist)=999;
    Dist(Dist<=condist)=1;
    Dist(Dist==999)=0;
    Dist=Dist-diag(diag(Dist));
    
    NodeMetrix.Neighbor=Dist;
    NodeMetrix.cur_timeWindow.CPNeighbor=Neighbor.*Dist;
end

function NodeMetrix=update_Nexthop(NodeMetrix)
%   update the dist from node to BS and the hop of each node
    
    Neighbor=NodeMetrix.Neighbor;
    DTNode=NodeMetrix.DistToNode;
    condist=NodeMetrix.condist;
    NH=NodeMetrix.data(4,:);
    Energy_Percen=NodeMetrix(5,:)/(NodeMetrix.MaxEnergy+1);
    position=NodeMetrix.data(1:2,:);
    
    
%     we suppose BS is (0,0),so the DistToBS can be calculated like
    DTBS=sqrt(power(position(1,:),2)+power(position(2,:),2));
    DTBS(DTBS>condist)=inf;
    DTBS=DTBS.*(1-Energy_Percen);
    NH(find(DTBS<=condist))=-1;
    
    [dist,Index]=sort(Neighbor,2,'descend');
    [nrow,ncol]=size(Neighbor);
    alpha=1000;
    while alpha~=0
        preDTBS=DTBS;
        for i=1:nrow
            for j=1:ncol
                if dist(i,j)==0
                    break;
                else
                    k=Index(i,j);
                    pd=DTNode(i,k).*(1-Energy_Percen(i))+DTBS(k);
                    if DTBS(i)>pd
                        DTBS(i)=pd;
                        NH(i)=k;
                    end
                end
            end
        end
%         if alpha no change,that means we find the short path
        alpha=sum(DTBS-preDTBS);
    end
    
    NodeMetrix.data(4,:)=NH;
    NodeMetrix.data(3,:)=DTBS;
    
end

function NodeMetrix=update_N_use(NodeMetrix)
%     NodeMetrix.cur_timeWindow.N_use(i,j)
    Neighbor=NodeMetrix.Neighbor;

    time_period=NodeMetrix.update_timeperiod;
    SSpd=NodeMetrix.SendSpd;
    MaxPacket=SSpd*time_period;
    NodeMetrix.cur_timeWindow.N_use=Neighbor.*MaxPacket;
end

function NodeMetrix=update_pene(NodeMetrix)
    pene=NodeMetrix.cur_timeWindow.pene;
    pene=pene/NodeMetrix.MaxEnergy;
    NodeMetrix.cur_timeWindow.pene=pene;
end

