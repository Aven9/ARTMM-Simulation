function res = per(lb, lc, bn, ratio, sl, nl, di, r, depth, N)
    %计算包错误率
    p_bler = bler(lb, lc, bn, ratio, sl, nl, di, r, depth);
    res = 1-(1-p_bler)^N;
end

function res = bler(lb, lc, bn, ratio, sl, nl, di, r, depth)
% 计算块错误率
% lb是块码的长度，lc是比特的纠错能力
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
% 计算比特误码率(16QAM)
% params: bn: 噪声带宽
%           r: 数据的速率
%
    this_snr = snr(sl, nl, di, r, depth);
    res = 3/8*erfc(sqrt(0.4*this_snr*bn/ratio));
end

% 瞎定义的
% x = per(5, 1, 3, 4, 25, 6, 7, 8, 9, [1,3,4]);
function res = tl(r, depth)
% 计算传输损失tl
%   params: 
%       r: 传输范围
%       depth: 水深
% 全局：DEPTH_THRESHOLD
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
% 计算信噪比 snr
% params: sl: 源级；
%           tl: 传输损失
%           nl: 噪音级别
%           di: 指向性指数
    t_tl = tl(r, depth);
    res = sl-t_tl-nl+di;
end





