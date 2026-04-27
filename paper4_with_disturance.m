clear all;
clc;close all;

%参数赋初值
m=150;
n=55;
%x1(1:m,1:n)=0;
%x2(1:m,1:n)=0;
x3(1:m,1:n)=0;
x4(1:m,1:n)=0;
%u1(1:m,1:n)=0;
%u2(1:m,1:n)=0;
u3(1:m,1:n)=0;
u4(1:m,1:n)=0;
y1(1:m,1:n)=0;
y2(1:m,1:n)=0;
e1(1:m+1,1:n)=0;
e2(1:m+1,1:n)=0;
e1_sum(1:m+1)=0;
e2_sum(1:m+1)=0;
e1_abs(1:m+1,1:n)=0;
e2_abs(1:m+1,1:n)=0;
e1_sum(1, 1) = 0;  % 迭代0的误差设为0
e2_sum(1, 1) = 0;  % 迭代0的误差设为0

W11 = [0.75, 0]; W12 = [0.25, 0]; L11 = [0.3  0]; L12 = [0.65 -0.15];
W21 = [0, 0.75]; W22 = [0, 0.25]; L21 = [-0.6 -0.01]; L22 = [0.7 0.15];



d_w1 = load('w1.mat'); fn_w1 = fieldnames(d_w1); w1 = d_w1.(fn_w1{1});
d_w2 = load('w2.mat'); fn_w2 = fieldnames(d_w2); w2 = d_w2.(fn_w2{1});
d_v1 = load('v1.mat'); fn_v1 = fieldnames(d_v1); v1 = d_v1.(fn_v1{1});
d_v2 = load('v2.mat'); fn_v2 = fieldnames(d_v2); v2 = d_v2.(fn_v2{1});




%令150次迭代的x(1)随机变化
rA=unifrnd(-0.15,0.25,10,1);
% rB=-rA;
rB(70,1)=0;
rC(70,1)=0;
rD=[rA;rB;rC;];
x3(1:150,1)=rD(randperm(numel(rD)));
x4(1:150,1)=rD(randperm(numel(rD)));

%随机试验时间长度
Nk(1,1:m+1)=randi([45,55],1,m+1);


% %输出期望轨迹
% for n=0:55
%     y_d1(1,n+1)=0.018*n*(1+cos(4*pi*n/50-pi));
%     y_d2(1,n+1)=0.7*(1+sin(2*pi*n/50-pi/2));y_d2(1, n+1) = 2*log10(n/50)+2
% end
for n = 0:55
    if n < 25
    y_d1(1,n+1)=0.015*n*(1+cos(4*pi*n/50-pi));  
    y_d2(1,n+1)=0.8*(1+sin(2*pi*n/50-pi/2));

    else
    y_d1(1,n+1)=-0.018*n*(1+cos(4*pi*n/50-pi)); 
    y_d2(1,n+1)=0.8*(1+sin(2*pi*n/50-pi/2));

    end
end
%迭代试验
for k=1:m
    y1(k,1)=[0.15*exp(-1/100) 0]*[x3(k,1);x4(k,1)]+v1(k,1);
    y2(k,1)=[0 0.4*exp(-1/100)]*[x3(k,1);x4(k,1)]+v2(k,1);
    tk=Nk(1,m);
    
    if tk<50
        for t=2:tk

            if mod(k, 2) == 0  % 偶数迭代
                A11 = 0; A12=1.2; B11 = exp(-(t-1)/100); B12 = 0;
                A21 = 1.2; A22=0; B21 = 0; B22 =5;
                C11 = 0.15*exp(-t/100); C12=0;
                C21 = 0; C22 = 0.4*exp(-t/100);
            else  % 奇数迭代
                % A11 = 0; A12=1.3; A21 =1 ;  A22=0;
                % B11 = exp(-(t-1)/100); B12 = 0;  B21 =0;B22 =5.2*cos(t) ;
                A11 = 0; A12=1.18; B11 = exp(-(t-1)/100); B12 = 0;
                A21 = 1.22; A22=0; B21 = 0; B22 =4.9;
                C11 = 0.15*exp(-t/100); C12=0;
                C21 = 0; C22 = 0.41*exp(-t/100);
            end

            %第k次迭代的x(t)
            %x1(k,t)=[0.4 0]*[x1(k,t-1);x2(k,t-1)]+[0.06 0.8]*[u1(k,t-1);u2(k,t-1)];
            %x2(k,t)=[0.65 0.2]*[x1(k,t-1);x2(k,t-1)]+[5.6 0.5]*[u1(k,t-1);u2(k,t-1)];
            x3(k,t)=A11*sin(x3(k,t-1))+A12*sin(x4(k,t-1))+cos(t-1)+[B11 B12]*[u3(k,t-1);u4(k,t-1)]+w1(k,t-1);
            x4(k,t)=A21*cos(x3(k,t-1))+A22*cos(x4(k,t-1))+[B21 B22]*[u3(k,t-1);u4(k,t-1)]+w2(k,t-1);

            %输出轨迹：第k次迭代的y(t)
            y1(k,t)=[C11 C12]*[x3(k,t);x4(k,t)]+v1(k,t-1);
            y2(k,t)=[C21 C22]*[x3(k,t);x4(k,t)]+v2(k,t-1);

            %误差（未修订）：第k次迭代的e(0)
            e1(k,1)=y_d1(1,1)-y1(k,1);
            e2(k,1)=y_d2(1,1)-y2(k,1);

            %误差（未修订）：第k次迭代的e(t)和e(t+1)
            e1(k,t)=y_d1(1,t)-y1(k,t);
            e2(k,t)=y_d2(1,t)-y2(k,t);
            e1(k,t+1)=y_d1(1,t+1)-C11*(A11*sin(x3(k,t))+A12*sin(x4(k,t))+cos(t)+[B11 B12]*[u3(k,t);u4(k,t)]);
            e2(k,t+1)=y_d2(1,t+1)-C22*(A21*cos(x3(k,t))+A22*cos(x4(k,t))+[B21 B22]*[u3(k,t);u4(k,t)]);
            e1_abs(k,t-1)=abs(e1(k,t-1));
            e2_abs(k,t-1)=abs(e2(k,t-1));
            if t==tk
                e1_abs(k,t)=abs(e1(k,t));
                e2_abs(k,t)=abs(e2(k,t));
            end

            %第k次迭代的u(1)
            %u1(k+1,1)=u1(k,1)+[0.04 0.07]*[e1(k,2);e2(k,2)]+[0.02 0.01]*[e1(k+1,1);e2(k+1,1)];
            %u2(k+1,1)=u2(k,1)+[0.07 0.01]*[e1(k,2);e2(k,2)]+[0.05 0.03]*[e1(k+1,1);e2(k+1,1)];
            u3(k+2,1)=W11*[u3(k+1,1);u4(k+1,1)]+W12*[u3(k,1);u4(k,1)]+L11*[e1(k+1,2);e2(k+1,2)]+L12*[e1(k,2);e2(k,2)];
            u4(k+2,1)=W21*[u3(k+1,1);u4(k+1,1)]+W22*[u3(k,1);u4(k,1)]+L21*[e1(k+1,2);e2(k+1,2)]+L22*[e1(k,2);e2(k,2)];

            %第1次迭代的u(t)
            if k==1
                %u1(k,t)=0;
                %u2(k,t)=0;
                u3(k,t)=0;
                u4(k,t)=0;
                %第k次迭代的u(t)
            elseif k==2
                u3(k,t)=0;
                u4(k,t)=0;
            else
                %u1(k,t)=u1(k-1,t)+[0.04 0.07]*[e1(k-1,t+1);e2(k-1,t+1)]+[0.02 0.01]*[e1(k,t);e2(k,t)];
                %u2(k,t)=u2(k-1,t)+[0.07 0.01]*[e1(k-1,t+1);e2(k-1,t+1)]+[0.05 0.03]*[e1(k,t);e2(k,t)];
                u3(k,t)=W11*[u3(k-1,t);u4(k-1,t)]+W12*[u3(k-2,t);u4(k-2,t)]+L11*[e1(k-1,t+1);e2(k-1,t+1)]+L12*[e1(k-2,t+1);e2(k-2,t+1)];
                u4(k,t)=W21*[u3(k-1,t);u4(k-1,t)]+W22*[u3(k-2,t);u4(k-2,t)]+L21*[e1(k-1,t+1);e2(k-1,t+1)]+L22*[e1(k-2,t+1);e2(k-2,t+1)];
            end
        end
    end
    
    if tk>=50
        for t=2:50

            if mod(k, 2) == 0  % 偶数迭代
                A11 = 0; A12=1.2; B11 = exp(-(t-1)/100); B12 = 0;
                A21 = 1.2; A22=0; B21 = 0; B22 =5;
                C11 = 0.15*exp(-t/100); C12=0;
                C21 = 0; C22 = 0.4*exp(-t/100);
            else  % 奇数迭代
                % A11 = 0; A12=1.3; A21 =1 ;  A22=0;
                % B11 = exp(-(t-1)/100); B12 = 0;  B21 =0;B22 =5.2*cos(t) ;
                A11 = 0; A12=1.18; B11 = exp(-(t-1)/100); B12 = 0;
                A21 = 1.22; A22=0; B21 = 0; B22 =4.9;
                C11 = 0.15*exp(-t/100); C12=0;
                C21 = 0; C22 = 0.41*exp(-t/100);
            end
            x3(k,t)=A11*sin(x3(k,t-1))+A12*sin(x4(k,t-1))+cos(t-1)+[B11 B12]*[u3(k,t-1);u4(k,t-1)]+w1(k,t-1);
            x4(k,t)=A21*cos(x3(k,t-1))+A22*cos(x4(k,t-1))+[B21 B22]*[u3(k,t-1);u4(k,t-1)]+w2(k,t-1);
        
            %输出轨迹：第k次迭代的y(t)
            y1(k,t)=[C11 C12]*[x3(k,t);x4(k,t)]+v1(k,t-1);
            y2(k,t)=[C21 C22]*[x3(k,t);x4(k,t)]+v2(k,t-1);
        
            %误差（未修订）：第k次迭代的e(0)
            e1(k,1)=y_d1(1,1)-y1(k,1);
            e2(k,1)=y_d2(1,1)-y2(k,1);
        
            %误差（未修订）：第k次迭代的e(t)和e(t+1)
            e1(k,t)=y_d1(1,t)-y1(k,t);
            e2(k,t)=y_d2(1,t)-y2(k,t);
            e1(k,t+1)=y_d1(1,t+1)-C11*(A11*sin(x3(k,t))+A12*sin(x4(k,t))+cos(t)+[B11 B12]*[u3(k,t);u4(k,t)]);
            e2(k,t+1)=y_d2(1,t+1)-C22*(A21*cos(x3(k,t))+A22*cos(x4(k,t))+[B21 B22]*[u3(k,t);u4(k,t)]);
            e1_abs(k,t-1)=abs(e1(k,t-1));
            e2_abs(k,t-1)=abs(e2(k,t-1));
        
            %第k次迭代的u(1)
            %u1(k+1,1)=u1(k,1)+[0.04 0.07]*[e1(k,2);e2(k,2)]+[0.02 0.01]*[e1(k+1,1);e2(k+1,1)];
            %u2(k+1,1)=u2(k,1)+[0.07 0.01]*[e1(k,2);e2(k,2)]+[0.05 0.03]*[e1(k+1,1);e2(k+1,1)];
            u3(k+2,1)=W11*[u3(k+1,1);u4(k+1,1)]+W12*[u3(k,1);u4(k,1)]+L11*[e1(k+1,2);e2(k+1,2)]+L12*[e1(k,2);e2(k,2)];
            u4(k+2,1)=W21*[u3(k+1,1);u4(k+1,1)]+W22*[u3(k,1);u4(k,1)]+L21*[e1(k+1,2);e2(k+1,2)]+L22*[e1(k,2);e2(k,2)];
        
            %第1次迭代的u(t)
            if k==1
                %u1(k,t)=0;
                %u2(k,t)=0;
                u3(k,t)=0;
                u4(k,t)=0;
            %第k次迭代的u(t)
            elseif k==2
                u3(k,t)=0;
                u4(k,t)=0;
            else
                %u1(k,t)=u1(k-1,t)+[0.04 0.07]*[e1(k-1,t+1);e2(k-1,t+1)]+[0.02 0.01]*[e1(k,t);e2(k,t)];
                %u2(k,t)=u2(k-1,t)+[0.07 0.01]*[e1(k-1,t+1);e2(k-1,t+1)]+[0.05 0.03]*[e1(k,t);e2(k,t)];
                u3(k,t)=W11*[u3(k-1,t);u4(k-1,t)]+W12*[u3(k-2,t);u4(k-2,t)]+L11*[e1(k-1,t+1);e2(k-1,t+1)]+L12*[e1(k-2,t+1);e2(k-2,t+1)];
                u4(k,t)=W21*[u3(k-1,t);u4(k-1,t)]+W22*[u3(k-2,t);u4(k-2,t)]+L21*[e1(k-1,t+1);e2(k-1,t+1)]+L22*[e1(k-2,t+1);e2(k-2,t+1)];
            end
        end 
        
        for t=51:tk

            if mod(k, 2) == 0  % 偶数迭代
                A11 = 0; A12=1.2; B11 = exp(-(t-1)/100); B12 = 0;
                A21 = 1.2; A22=0; B21 = 0; B22 =5;
                C11 = 0.15*exp(-t/100); C12=0;
                C21 = 0; C22 = 0.4*exp(-t/100);
            else  % 奇数迭代
                % A11 = 0; A12=1.3; A21 =1 ;  A22=0;
                % B11 = exp(-(t-1)/100); B12 = 0;  B21 =0;B22 =5.2*cos(t) ;
                A11 = 0; A12=1.18; B11 = exp(-(t-1)/100); B12 = 0;
                A21 = 1.22; A22=0; B21 = 0; B22 =4.9;
                C11 = 0.15*exp(-t/100); C12=0;
                C21 = 0; C22 = 0.41*exp(-t/100);
            end
            %第k次迭代的x(t)
            %x1(k,t)=[0.4 0]*[x1(k,t-1);x2(k,t-1)]+[0.06 0.8]*[u1(k,t-1);u2(k,t-1)];
            %x2(k,t)=[0.65 0.2]*[x1(k,t-1);x2(k,t-1)]+[5.6 0.5]*[u1(k,t-1);u2(k,t-1)];
            x3(k,t)=A11*sin(x3(k,t-1))+A12*sin(x4(k,t-1))+cos(t-1)+[B11 B12]*[u3(k,t-1);u4(k,t-1)]+w1(k,t-1);
            x4(k,t)=A21*cos(x3(k,t-1))+A22*cos(x4(k,t-1))+[B21 B22]*[u3(k,t-1);u4(k,t-1)]+w2(k,t-1);
        
            %输出轨迹：第k次迭代的y(t)
            y1(k,t)=[C11 C12]*[x3(k,t);x4(k,t)]+v1(k,t-1);
            y2(k,t)=[C21 C22]*[x3(k,t);x4(k,t)]+v2(k,t-1);
        
            %误差（未修订）：第k次迭代的e(0)
            %e1(k,1)=y_d1(1,1)-y1(k,1);
            %e2(k,1)=y_d2(1,1)-y2(k,1);
        
            %误差（未修订）：第k次迭代的e(t)和e(t+1)
            e1(k,t)=0;
            e2(k,t)=0;
            e1(k,t+1)=0;
            e2(k,t+1)=0;
            e1_abs(k,t-1)=abs(e1(k,t-1));
            e2_abs(k,t-1)=abs(e2(k,t-1));
            if t==tk
                e1_abs(k,t)=abs(e1(k,t));
                e2_abs(k,t)=abs(e2(k,t));
            end

            if k==1
                u3(k,t)=0;
                u4(k,t)=0;
            elseif k==2
                u3(k,t)=0;
                u4(k,t)=0;
            else
                u3(k,t)=W11*[u3(k-1,t);u4(k-1,t)]+W12*[u3(k-2,t);u4(k-2,t)]+L11*[e1(k-1,t+1);e2(k-1,t+1)]+L12*[e1(k-2,t+1);e2(k-2,t+1)];
                u4(k,t)=W21*[u3(k-1,t);u4(k-1,t)]+W22*[u3(k-2,t);u4(k-2,t)]+L21*[e1(k-1,t+1);e2(k-1,t+1)]+L22*[e1(k-2,t+1);e2(k-2,t+1)];
            end
        end
    end
end

for m=1:150
    for t=1:55
        e1_sum(1,m)=e1_sum(1,m)+e1_abs(m,t);
        e2_sum(1,m)=e2_sum(1,m)+e2_abs(m,t);
    end
end

figure
axis([0 60 -1 2]);
subplot(2,1,1);
plot(0:49,y_d1(1:50),'k','LineWidth', 1.5 );hold on;
plot(0:Nk(38)-1,y1(38,1:Nk(1,38)), 'Color', [1, 0, 0],'LineWidth', 1.5 , 'LineStyle', '--');hold on;
plot(0:Nk(63)-1,y1(63,1:Nk(1,63)), 'Color', [0, 1, 0],'LineWidth',1.5 , 'LineStyle', ':');hold on;
legend('y_d1(t)','y_{38}(t)','y_{63}(t)');
xlabel('Time t');
ylabel('Output');
ax = gca;
box(ax, 'on');
ax.TickDir = 'in';
ax.YAxisLocation = 'left';
xlim([0, 50]);

subplot(2,1,2);
%axis([0 120 -1 2]);
plot(0:49,y_d2(1:50), 'k','LineWidth', 1.5);hold on;
plot(0:Nk(38)-1,y2(38,1:Nk(1,38)), 'Color', [1, 0, 0],'LineWidth', 1.5 , 'LineStyle', '--');hold on;
plot(0:Nk(63)-1,y2(63,1:Nk(1,63)), 'Color', [0, 1, 0],'LineWidth', 1.5 , 'LineStyle', ':');hold on;
legend('y_d2(t)','y_{38}(t)','y_{63}(t)');
xlabel('Time t');
ylabel('Output');
ax = gca;
box(ax, 'on');
ax.TickDir = 'in';
ax.YAxisLocation = 'left';
xlim([0, 50]);

figure
subplot(2,1,1);
plot(0:149,e1_sum(1:150),'-', 'Color', [1, 0, 0], 'LineWidth', 1.5);hold on;
legend('Case 1');
xlabel('literation k');
ylabel('CE1_k');
ax = gca;
box(ax, 'on');
ax.TickDir = 'in';
ax.YAxisLocation = 'left';
xlim([0, 150]);

subplot(2,1,2);
plot(0:149,e2_sum(1:150),'-', 'Color', [1, 0, 0], 'LineWidth', 1.5);hold on;
legend('Case 2');
xlabel('literation k');
ylabel('CE2_k');
ax = gca;
box(ax, 'on');
ax.TickDir = 'in';
ax.YAxisLocation = 'left';
xlim([0, 150]);

figure
subplot(2,1,1);
plot(0:149,x3(1:150,1),'ks-', 'LineWidth', 1);hold on;
xlabel('literation l');
ylabel('x3(1)_l');
ax = gca;
box(ax, 'on');
ax.TickDir = 'in';
ax.YAxisLocation = 'left';
xlim([0, 150]);

subplot(2,1,2);
plot(0:149,x4(1:150,1),'ks-', 'LineWidth', 1);hold on;
xlabel('literation k');
ylabel('x4(1)_l');
ax = gca;
box(ax, 'on');
ax.TickDir = 'in';
ax.YAxisLocation = 'left';
xlim([0, 150]);

