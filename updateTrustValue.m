function [T_data, T_link, T_node] = updateTrustValue(T_old_data, T_old_link, T_old_node, s, CPNeighbor)
%  ����������ѡ��delta��ֵΪ0.5��t��ʾ���ǵ�ǰʱ��㣬t0��ʾ������һ������ֵ�����ʱ��㣬����t-t0��ʾ����һ��ʱ�䴰�ڵĳ���
% �����������е�t��λ�趨Ϊ��һ������ʱ�䡣������㹻С���ڵ����ͱ�������ʱ����Ժ��ԣ�����ֻ��Ҫ������ش�һ���ڵ㵽��һ���ڵ��ʱ����Ϊ���Ĵ���ʱ��
%  ����ˮ�´������ٶ���1433m/s�������趨�ڵ�ͨ�ž���Ϊ50m��ʱ�䴰��Ϊ10��������ʱ��ԼΪ50*10/1433��1/3=t-t0
%   �˴���ʾ��ϸ˵��

    % Ȩ�ز���
    w_decay = 0.8465;
    
    % �������
    node_link = [1,1,1,1,1; 2,2,2,2,2; 3,3,3,3,3; 1,2,3,4,5; 1,2,3,4,5];
    node_data = [3,3,3,3,3; 3,3,3,3,3; 3,3,3,3,3; 1,2,3,4,4; 1,2,3,4,5];
    data_link = [3,3,3,2,1; 3,3,3,1,2; 3,3,3,3,3; 5,5,3,3,3; 5,5,3,3,3];
    
    % ������ֵ��Ϊ1-5�Ĳ�ͬ����
    T_data = qualifyMetrix(T_old_data);
    T_link = qualifyMetrix(T_old_link);
    T_node = qualifyMetrix(T_old_node);
    
    T_inter_d = arrayfun(@(x, y) node_link(x, y), T_node, T_link);
    T_inter_l = arrayfun(@(x, y) node_data(x, y), T_node, T_data);
    T_inter_n = arrayfun(@(x, y) data_link(x, y), T_data, T_link);
    
    T_link = w_decay*T_old_link+(1-w_decay)*T_inter_l;
    T_data = w_decay*T_old_data+(1-w_decay)*T_inter_d;
    
    % ���½ڵ����ε�w_decay,
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
% ��ɢ������ֵ
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
% ��������w_decay
    rm = get_RM(s);
    extra_w = exp(1-rm);
end

function rm = get_RM(s)
% ����rm
%   timeSlideΪpre���TransSeq
    pnum = size(s, 1);

    row = sum(s);
    column = sum(s, 2);
    n_i = row+column';
    n_i = repmat(n_i, pnum, 1);
    rm = arrayfun(@(x, y) x/y, s, n_i);
    % ����Ҫ��һ��ϵ�� rm = rm.*beta^(1./s)
    
    rm = rm.*0.5^(1./s);
end





