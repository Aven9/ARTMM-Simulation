function [new_x,new_y]=Get_position(pre_x,pre_y,pre_t,deta)
    Vx=Get_Vx(pre_x,pre_y,pre_t);
    Vy=Get_Vy(pre_x,pre_y,pre_t);
    syms x y t    
    f=Get_func;
    value=subs(f,{x,y,t},{pre_x,pre_y,pre_t});
%     new_x=double(pre_x+-1*Vx*deta);
%     new_y=double(pre_y+Vy*deta);
    new_x=double(pre_x+-1*Vy.*value*deta);
    new_y=double(pre_y+Vx.*value*deta);

%     new_x=0;
%     new_y=0;
end

function Vx=Get_Vx(pre_x,pre_y,pre_t)
    syms x y t    
    f=Get_func;
    V=diff(f,x);
    Vx=subs(V,{x,y,t},{pre_x,pre_y,pre_t});
end

function Vy=Get_Vy(pre_x,pre_y,pre_t)
    syms x y t
    f=Get_func;
    V=diff(f,y);
    Vy=subs(V,{x,y,t},{pre_x,pre_y,pre_t});
end

function F=Get_func
    syms x y t
    A=1.2;
    epsilon=0.3;
    omega=0.4;
    k=2*pi/7.5;
    c=0.12;
    
    f1=k*(x-c*t);
    Bt=A+epsilon*cos(omega*t);
    
    F_up=y-Bt*sin(f1);
    F_down=sqrt(1+k^2*Bt^2*cos(f1)^2);
    F=-tanh(F_up/F_down);
end