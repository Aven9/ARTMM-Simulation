function timeSlide = init_time_slide(pnum,packetnum)
    timeSlide.TransSeq=ones(pnum,pnum,packetnum)*(-1);
    % ��ʼ��������Ҫ����ʵ���������
    timeSlide.N_use = zeros(pnum, pnum);
    timeSlide.n_use = zeros(pnum, pnum);
    timeSlide.prr = zeros(pnum, pnum);
    timeSlide.lq = zeros(pnum, pnum);
    timeSlide.lc = zeros(pnum, pnum);
    timeSlide.s = zeros(pnum, pnum);
    timeSlide.f = zeros(pnum, pnum);
    timeSlide.Vd = zeros(pnum, pnum);
    timeSlide.pene = zeros(1, pnum);
    % ��·����ֵ��ʼ��Ϊ0.5
    timeSlide.T_link = ones(pnum, pnum)*0.5;
    % ��������ֵ��ʼ��Ϊ0.5
    timeSlide.T_data = ones(pnum, pnum)*0.5;
    % �ڵ��ʵ�ȳ�ʼ��Ϊ0.5
    timeSlide.NH = ones(pnum, pnum)*0.5;
    timeSlide.NC = ones(1, pnum)*0.5;
    timeSlide.T_node = ones(pnum, pnum)*0.5;
end
