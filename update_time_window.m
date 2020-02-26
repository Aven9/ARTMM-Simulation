function NodeMetrix = update_time_window(NodeMetrix)
%����ʱ�䴰�ڣ����и�����ʾ��NodeMetrix.timeWindow��
%   input param: 
%       NodeMetrix: �ṩ�ɵ�window��Ϣ
%       TransSeq: �µĴ���״̬����(��ά����)
    NodeMetrix.pre_timeWindow = NodeMetrix.cur_timeWindow;
    TransSeq = NodeMetrix.cur_timeWindow.TransSeq;
    pnum = NodeMetrix.nodenum;
    packetnum = NodeMetrix.UTP*SSpd;
    % ����������·��prr, s��f
    [NodeMetrix.cur_timeWindow.prr, NodeMetrix.cur_timeWindow.s, NodeMetrix.cur_timeWindow.f]...
            = get_prr_s_f(TransSeq, pnum, packetnum);
    % ����������·��lq
    NodeMetrix.cur_timeWindow.lq = get_lq(NodeMetrix.PER, NodeMetrix.cur_timeWindow.prr);
    % ����������·��N_use, ��д��
%     NodeMetrix.cur_timeWindow.N_use = updateNuse();
    % ����������·��n_use, ��д��
%     NodeMetrix.cur_timeWindow.n_use = updatenuse();
    % ����������·��lc, ���һ������Ϊ��ֵtheta
    NodeMetrix.cur_timeWindow.lc = get_lc(NodeMetrix.cur_timeWindow.n_use, NodeMetrix.pre_timeWindow.n_use, NodeMetrix.pre_timeWindow.N_use, NodeMetrix.pre_timeWindow.lc, 0.5);
    % ����������·����
    NodeMetrix.cur_timeWindow.T_link = get_T_link(NodeMetrix.cur_timeWindow.lq, NodeMetrix.cur_timeWindow.lc);
    % ����������������
    NodeMetrix.cur_timeWindow.T_data = get_T_data(cur_timeWindow.Vd);
    % ��ȡNC��NH
    NH = get_NH(NodeMetrix.cur_timeWindow.s, NodeMetrix.cur_timeWindow.f);
    NC = get_NC(NodeMetrix.data(5, :), NodeMetrix.cur_timeWindow.pene);
    % �������нڵ��ֱ������
    NodeMetrix.cur_timeWindow.T_direct = get_direct_T_node(NH, NC);
    
    % ��������ֵ
    
    [NodeMetrix.cur_timeWindow.T_data, NodeMetrix.cur_timeWindow.T_link, NodeMetrix.cur_timeWindow.T_node] = ...
        updateTrustValue(T_data, T_link, T_node, NodeMetrix.cur_timeWindow.s,  NodeMetrix.cur_timeWindow.CPNeighbor);
    
    % ������ֵ
    NodeMetrix.cur_timeWindow.Vd(:,:)=0;
    NodeMetrix.cur_timeWindow.n_use(:,:)=0;
    NodeMetrix.cur_timeWindow.TransSeq(:,:,:)=-1;
end


function [prr,s,f] = get_prr_s_f(TransSeq, pnum, packetnum)
% ����prr
%   TransSeqΪ��ά����
%   ���ؽ��Ϊһ��n�о���
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
% ���㵥��prr
% seqÿ��Ϊ�������ڵ������
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
% ����������·������
    cap = length(n_use);
    threshold = ones(cap, cap)*theta;
    lc = arrayfun(@lc_for_single_element, n_use, n_use_old, N_use_old, lc_old, threshold);
end

function res = lc_for_single_element(n_use, n_use_old, N_use_old, lc_old, theta)
% ���㵥����·����
%   n_use��n_use(i)
%   n_use_old: n_use(i-1)
%   N_use_old: N_use(i-1)
    if abs(n_use-n_use_old) <= theta
        res = n_use/N_use_old;
    else
        res = lc_old;
    end
end


function lq = get_lq(per, prr)
% ������·����
% ����per��Ҫ�Ĳ�����W, lb, lc, bn, ratio, sl, nl, di, r, depth, N
%   param: per: const����
%   prr: ��ά����
    lq = (1-per)*prr;
end


function tlink = get_T_link(lq, lc)
% ����������·����
%   lq, lcΪpnum*pnum����
    tlink = arrayfun(@T_link, lq, lc);
end

function res = T_link(lq, lc)
%���㵥��T_link
%   lq, lcΪ����
    if lq>=0.5
        res = 0.5+(lq-0.5)*lc;
    else
        res = lq*lc;
    end
end


function tdata = get_T_data(vd)
%�������е���������
%   vdΪpnum*pnum����
    tdata = arrayfun(@T_data, vd);
end

function res = T_data(vd)
%���㵥����������
    % �������ݵ���̬�ֲ��ܶȺ���, �ݶ���ֵΪ0.5, ����Ϊ1.
    func = @(x) normpdf(x, 0.5, 1);
    res = 2*integral(func, vd, inf);
end 


function T_direct = get_direct_T_node(NH,NC)
%����ڵ���ֱ������
%   NHΪpnum*pnum������Ϊ���ܷ�����Ϊ���ͷ�
%   NCΪ1*pnum������Ϊ���ͷ�
    NC_rep = repmat(NC, length(NC), 1);
    T_direct = arrayfun(@t_direct, NH, NC_rep);
end

function res = t_direct(nh, nc)
%���㵥�����ͷ����ڽ��շ���������ֵ
    if nh > 0.5
        res = 0.5+(nh-0.5)*nc;
    else
        res = nh*nc;
    end
end


function NC = get_NC(energy, pene)
%��������NC
%   energy: 1��pnum�о���, ʣ������
%   pene��1��pnum�о���
    NC = arrayfun(@single_nc, energy, pene);
end

function nc = single_nc(energy, pene)
% ���㵥���ڵ�������ʣ��������ֵtheta��ʱ��Ϊ3
    theta = 3;
    if energy > theta
        nc = 1-pene;
    else
        nc = 0;
    end

end

function NH = get_NH(s, f)
% �������нڵ��ʵ��
%   
    NH = arrayfun(@singleNH, s, f);
end

function nh = singleNH(s, f)
    b = s/(s+f+1);
    u = 1/(s+f+1);
    nh = 2*b+u/2;
end








