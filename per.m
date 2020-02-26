function res = per(lb, lc, bn, ratio, sl, nl, di, r, depth, N)
    %�����������
    p_bler = bler(lb, lc, bn, ratio, sl, nl, di, r, depth);
    res = 1-(1-p_bler)^N;
end

function res = bler(lb, lc, bn, ratio, sl, nl, di, r, depth)
% ����������
% lb�ǿ���ĳ��ȣ�lc�Ǳ��صľ�������
    p_ber = ber(bn, ratio, sl, nl, di, r, depth);
    res = 0;
    for i = lc+1: lb
%         a=factorial(i)/factorial(i-lc-1);
%         b=p_ber^lb;
%         c=(1-p_ber)^(lb-i)
        res = res + factorial(i)/factorial(i-lc-1)*p_ber^lb*(1-p_ber)^(lb-i);
    end
end
function res = ber(bn, ratio, sl, nl, di, r, depth)
% �������������(16QAM)
% params: bn: ��������
%           r: ���ݵ�����
%
    this_snr = snr(sl, nl, di, r, depth);
    res = 3/8*erfc(sqrt(0.4*this_snr*bn/ratio));
end

% Ϲ�����
% x = per(5, 1, 3, 4, 25, 6, 7, 8, 9, [1,3,4]);
function res = tl(r, depth)
% ���㴫����ʧtl
%   params: 
%       r: ���䷶Χ
%       depth: ˮ��
% ȫ�֣�DEPTH_THRESHOLD
%       ALPHA_S
%       ALPHA_D

DEPTH_THRESHOLD = 20;
ALPHA_S = 0.3;
ALPHA_D = 0.6;
    if depth >= DEPTH_THRESHOLD
        res = 10*log(r)+ALPHA_S*r*0.001;
    else
        res = 10*log(r)+ALPHA_D*r*0.001;
    end
end
function res = snr(sl, nl, di, r, depth)
% ��������� snr
% params: sl: Դ����
%           tl: ������ʧ
%           nl: ��������
%           di: ָ����ָ��
    t_tl = tl(r, depth);
    res = sl-t_tl-nl+di;
end





