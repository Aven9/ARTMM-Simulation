function NodeMetrix=Init_Node_Metrix(pnum)
% %   each unit is relevant to the certain node info
% %   positon of Node
%     NodeMatrix.PXY=rand(2,pnum);
% %   dist from node to BS
%     NodeMatrix.DistToBS=zeros(1,pnum);
% %   dist from node to other node
%     NodeMatrix.DistToNode=zeros(pnum,pnum);
% %   energy of node
%     NodeMatrix.Energy=zeros(1,pnum);
% %   trust value of node
%     NodeMatrix.Trustvalue=zeros(3,pnum);


%   each unit is relevant to the certain node info
%   first 2 row means positon of Node                       1,2
%   3rd row means dist from node to BS                      3
%   4th means next hop to BS                                4
%   5th means energy of node                                5
%   6th means num of packet need to be sended               6
    NodeMetrix.data=zeros(6,pnum);
    NodeMetrix.data(1:2,:)=rand(2,pnum);
    
%   dist from node to other node
    NodeMetrix.DistToNode=zeros(pnum,pnum);
%   Connecting state between node
    NodeMetrix.ConState=zeros(pnum,pnum);
%   position Neighbor between node
    NodeMetrix.Neighbor=zeros(pnum,pnum);
    
%   other property
%   the time length of update
    NodeMetrix.update_timeperiod=10;
%   num of node
    NodeMetrix.nodenum=pnum;
%   condist means the max distance of Node direct communication
    NodeMetrix.condist=50;
%   per packet need 5 seconds to produce
    NodeMetrix.ProduceSpd=5;
%   each node can send 1 packet per second
    NodeMetrix.SendSpd=1;
%   connect speed
    NodeMetrix.ConSpd=5;
%   MAX energy of node
    NodeMetrix.MaxEnergy=500;
%   PER packet error rate
    NodeMetrix.PER=0.3591;
    
%   time window
    % pre_timeWindow�����һ��ʱ�䴰����Ϣ
    % cur_timeWindow��ŵ�ǰʱ�䴰����Ϣ
        % TransSeq����հ�����(i, j, k)��ʾ�ڵ�i��j����·�ĵ�k�����ܰ���״̬
        % N_use���(i,j)�ڵ���·��������ʹ�ô���
        % n_use���(i,j)�ڵ���·������ʹ�ô���
        % n(i)��Žڵ�i����Ϣ
        %      prr��lq��lc��T_link, T_data, T_node
        
    SSpd=NodeMetrix.SendSpd;
    UTP=NodeMetrix.update_timeperiod;
    NodeMetrix.pre_timeWindow = init_time_slide(pnum,UTP*SSpd);
    NodeMetrix.cur_timeWindow = NodeMetrix.pre_timeWindow;

end
