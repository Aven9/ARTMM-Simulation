function timeSlide = init_time_slide(pnum,packetnum)
    timeSlide.TransSeq=ones(pnum,pnum,packetnum)*(-1);
    % 初始化可能需要根据实际情况调整
    timeSlide.N_use = zeros(pnum, pnum);
    timeSlide.n_use = zeros(pnum, pnum);
    timeSlide.prr = zeros(pnum, pnum);
    timeSlide.lq = zeros(pnum, pnum);
    timeSlide.lc = zeros(pnum, pnum);
    timeSlide.s = zeros(pnum, pnum);
    timeSlide.f = zeros(pnum, pnum);
    timeSlide.Vd = zeros(pnum, pnum);
    timeSlide.pene = zeros(1, pnum);
    % 链路信任值初始化为0.5
    timeSlide.T_link = ones(pnum, pnum)*0.5;
    % 数据信任值初始化为0.5
    timeSlide.T_data = ones(pnum, pnum)*0.5;
    % 节点诚实度初始化为0.5
    timeSlide.NH = ones(pnum, pnum)*0.5;
    timeSlide.NC = ones(1, pnum)*0.5;
    timeSlide.T_node = ones(pnum, pnum)*0.5;
end
