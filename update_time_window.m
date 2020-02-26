function NodeMetrix = update_time_window(NodeMetrix)
%更新时间窗口，所有更新显示在NodeMetrix.timeWindow里
%   input param: 
%       NodeMetrix: 提供旧的window信息
%       TransSeq: 新的传输状态序列(三维矩阵)
    NodeMetrix.pre_timeWindow = NodeMetrix.cur_timeWindow;
    TransSeq = NodeMetrix.cur_timeWindow.TransSeq;
    pnum = NodeMetrix.nodenum;
    packetnum = NodeMetrix.UTP*SSpd;
    % 更新所有链路的prr, s和f
    [NodeMetrix.cur_timeWindow.prr, NodeMetrix.cur_timeWindow.s, NodeMetrix.cur_timeWindow.f]...
            = get_prr_s_f(TransSeq, pnum, packetnum);
    % 更新所有链路的lq
    NodeMetrix.cur_timeWindow.lq = get_lq(NodeMetrix.PER, NodeMetrix.cur_timeWindow.prr);
    % 更新所有链路的N_use, 乱写的
%     NodeMetrix.cur_timeWindow.N_use = updateNuse();
    % 更新所有链路的n_use, 乱写的
%     NodeMetrix.cur_timeWindow.n_use = updatenuse();
    % 更新所有链路的lc, 最后一个参数为阈值theta
    NodeMetrix.cur_timeWindow.lc = get_lc(NodeMetrix.cur_timeWindow.n_use, NodeMetrix.pre_timeWindow.n_use, NodeMetrix.pre_timeWindow.N_use, NodeMetrix.pre_timeWindow.lc, 0.5);
    % 更新所有链路信任
    NodeMetrix.cur_timeWindow.T_link = get_T_link(NodeMetrix.cur_timeWindow.lq, NodeMetrix.cur_timeWindow.lc);
    % 更新所有数据信任
    NodeMetrix.cur_timeWindow.T_data = get_T_data(cur_timeWindow.Vd);
    % 获取NC，NH
    NH = get_NH(NodeMetrix.cur_timeWindow.s, NodeMetrix.cur_timeWindow.f);
    NC = get_NC(NodeMetrix.data(5, :), NodeMetrix.cur_timeWindow.pene);
    % 更新所有节点的直接信任
    NodeMetrix.cur_timeWindow.T_direct = get_direct_T_node(NH, NC);
    
    % 更新信任值
    
    [NodeMetrix.cur_timeWindow.T_data, NodeMetrix.cur_timeWindow.T_link, NodeMetrix.cur_timeWindow.T_node] = ...
        updateTrustValue(T_data, T_link, T_node, NodeMetrix.cur_timeWindow.s,  NodeMetrix.cur_timeWindow.CPNeighbor);
    
    % 清空相关值
    NodeMetrix.cur_timeWindow.Vd(:,:)=0;
    NodeMetrix.cur_timeWindow.n_use(:,:)=0;
    NodeMetrix.cur_timeWindow.TransSeq(:,:,:)=-1;
end


function [prr,s,f] = get_prr_s_f(TransSeq, pnum, packetnum)
% 计算prr
%   TransSeq为三维矩阵
%   返回结果为一行n列矩阵
    prr = zeros(pnum, pnum);
    s = zeros(pnum, pnum);
    f = zeros(pnum, pnum);
    for i=1: pnum
        seq = reshape(TransSeq(:, i, :), [pnum, packetnum]);
        for j=1: pnum
            [prr(i,j), s(i, j), f(i, j)] = calculate_prr(seq(j, :));
        end
    end
end

function [prr, s, f] = calculate_prr(seq)
% 计算单个prr
% seq每行为到其它节点的序列
    valid_seq = seq(find(seq>(-1)));
    
    s = length(find(valid_seq==1));
    f = length(find(valid_seq==0));
    
    if all(valid_seq==0)
        prr = 0;
    else
        n = find(valid_seq>(-1), 1, 'last');
        index = 1:n;
        n_metrix = ones(1, n)*n;
        func = @(x,i,n) 2*i*x/(n*(n+1));
        weights = arrayfun(func, valid_seq, index, n_metrix);
        prr = sum(weights.^2)/sum(weights);
        s_new = s + (1-prr)*(s+f);
        f = f-(1-prr)*(s+f);
        s = s_new;
    end
end

function lc = get_lc(n_use, n_use_old, N_use_old, lc_old, theta)
% 计算所有链路的容量
    cap = length(n_use);
    threshold = ones(cap, cap)*theta;
    lc = arrayfun(@lc_for_single_element, n_use, n_use_old, N_use_old, lc_old, threshold);
end

function res = lc_for_single_element(n_use, n_use_old, N_use_old, lc_old, theta)
% 计算单条链路容量
%   n_use：n_use(i)
%   n_use_old: n_use(i-1)
%   N_use_old: N_use(i-1)
    if abs(n_use-n_use_old) <= theta
        res = n_use/N_use_old;
    else
        res = lc_old;
    end
end


function lq = get_lq(per, prr)
% 计算链路质量
% 计算per需要的参数：W, lb, lc, bn, ratio, sl, nl, di, r, depth, N
%   param: per: const标量
%   prr: 二维矩阵
    lq = (1-per)*prr;
end


function tlink = get_T_link(lq, lc)
% 计算所有链路信任
%   lq, lc为pnum*pnum矩阵
    tlink = arrayfun(@T_link, lq, lc);
end

function res = T_link(lq, lc)
%计算单个T_link
%   lq, lc为标量
    if lq>=0.5
        res = 0.5+(lq-0.5)*lc;
    else
        res = lq*lc;
    end
end


function tdata = get_T_data(vd)
%计算所有的数据信任
%   vd为pnum*pnum矩阵
    tdata = arrayfun(@T_data, vd);
end

function res = T_data(vd)
%计算单个数据信任
    % 定义数据的正态分布密度函数, 暂定均值为0.5, 方差为1.
    func = @(x) normpdf(x, 0.5, 1);
    res = 2*integral(func, vd, inf);
end 


function T_direct = get_direct_T_node(NH,NC)
%计算节点间的直接信任
%   NH为pnum*pnum矩阵，列为接受方，行为发送方
%   NC为1*pnum矩阵，列为发送方
    NC_rep = repmat(NC, length(NC), 1);
    T_direct = arrayfun(@t_direct, NH, NC_rep);
end

function res = t_direct(nh, nc)
%计算单个发送方的在接收方处的信任值
    if nh > 0.5
        res = 0.5+(nh-0.5)*nc;
    else
        res = nh*nc;
    end
end


function NC = get_NC(energy, pene)
%计算所有NC
%   energy: 1行pnum列矩阵, 剩余能量
%   pene：1行pnum列矩阵
    NC = arrayfun(@single_nc, energy, pene);
end

function nc = single_nc(energy, pene)
% 计算单个节点能力，剩余能量阈值theta暂时设为3
    theta = 3;
    if energy > theta
        nc = 1-pene;
    else
        nc = 0;
    end

end

function NH = get_NH(s, f)
% 计算所有节点诚实度
%   
    NH = arrayfun(@singleNH, s, f);
end

function nh = singleNH(s, f)
    b = s/(s+f+1);
    u = 1/(s+f+1);
    nh = 2*b+u/2;
end








