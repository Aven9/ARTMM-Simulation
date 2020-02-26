function [T_data, T_link, T_node] = updateTrustValue(T_old_data, T_old_link, T_old_node, s, CPNeighbor)
%  我们在这里选定delta的值为0.5，t表示的是当前时间点，t0表示的是上一个信任值计算的时间点，所以t-t0表示的是一个时间窗口的长度
% 我们网络运行的t单位设定为发一个包的时间。假设包足够小，节点推送比特流的时间可以忽略，所以只需要计算比特从一个节点到另一个节点的时间作为包的传输时间
%  声音水下传播的速度是1433m/s，我们设定节点通信距离为50m，时间窗口为10个包，则时间约为50*10/1433≈1/3=t-t0
%   此处显示详细说明

    % 权重参数
    w_decay = 0.8465;
    
    % 运算规则
    node_link = [1,1,1,1,1; 2,2,2,2,2; 3,3,3,3,3; 1,2,3,4,5; 1,2,3,4,5];
    node_data = [3,3,3,3,3; 3,3,3,3,3; 3,3,3,3,3; 1,2,3,4,4; 1,2,3,4,5];
    data_link = [3,3,3,2,1; 3,3,3,1,2; 3,3,3,3,3; 5,5,3,3,3; 5,5,3,3,3];
    
    % 将信任值分为1-5的不同级别
    T_data = qualifyMetrix(T_old_data);
    T_link = qualifyMetrix(T_old_link);
    T_node = qualifyMetrix(T_old_node);
    
    T_inter_d = arrayfun(@(x, y) node_link(x, y), T_node, T_link);
    T_inter_l = arrayfun(@(x, y) node_data(x, y), T_node, T_data);
    T_inter_n = arrayfun(@(x, y) data_link(x, y), T_data, T_link);
    
    T_link = w_decay*T_old_link+(1-w_decay)*T_inter_l;
    T_data = w_decay*T_old_data+(1-w_decay)*T_inter_d;
    
    % 更新节点信任的w_decay,
    w_decay = get_ExtraWeight(s)+w_decay;
    T_node = w_decay*T_old_node+(1-w_decay)*T_inter_n;
    T_node = arrayfun(@update_node, CPNeighbor, T_node);
    
end

function tnode = update_node(flag, origin) 
    if flag == 0
        tnode = 0.5;
    else
        tnode = origin;
    end
end

function qMetrix = qualifyMetrix(Metrix)
% 离散化信任值
    MAX=max(max(Metrix));
    MIN=min(min(Metrix));
    if MAX==MIN
        MAX=MAX+0.001;
    end
    qMetrix=(Metrix-MIN)/(MAX-MIN);
    levelnum=5;
    for i=1:levelnum
        qMetrix(qMetrix<=(i*1/levelnum))=i;
    end
end

function extra_w = get_ExtraWeight(s)
% 计算额外的w_decay
    rm = get_RM(s);
    extra_w = exp(1-rm);
end

function rm = get_RM(s)
% 计算rm
%   timeSlide为pre里的TransSeq
    pnum = size(s, 1);

    row = sum(s);
    column = sum(s, 2);
    n_i = row+column';
    n_i = repmat(n_i, pnum, 1);
    rm = arrayfun(@(x, y) x/y, s, n_i);
    % 还需要乘一个系数 rm = rm.*beta^(1./s)
    
    rm = rm.*0.5^(1./s);
end





