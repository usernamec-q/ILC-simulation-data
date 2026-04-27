clear all;
clc;close all;
% 参数赋初值
m = 100; % 迭代次数
n = 120; % 每次迭代的最大时间步数
x1 = zeros(m, n);
x2 = zeros(m, n);
u1 = zeros(m, n);
u2 = zeros(m, n);
y1 = zeros(m, n);
y2 = zeros(m, n);
e1 = zeros(m+1, n);
e2 = zeros(m+1, n);
e1_sum = zeros(1, m+1);
e2_sum = zeros(1, m+1);
e1_abs = zeros(m+1, n);
e2_abs = zeros(m+1, n);
e1_sum(1, 1) = 0;  % 迭代0的误差设为0
e2_sum(1, 1) = 0;  % 迭代0的误差设为0
W11 = [0.7, 0];
W12 = [0.3, 0];
W21 = [0, 0.7];
W22 = [0, 0.3];
% =================微调后的控制增益 (满足收敛条件约等于 0.94) =================
L11 = [0.80,  0.03];  
L12 = [0.55, -0.04];  
L21 = [-0.01, 0.20];  
L22 = [0.01,  0.30];  
% =============================================================================
loaded_data1 = load('X1_0.mat');
variable_names1 = fieldnames(loaded_data1);
first_var_name1 = variable_names1{1};
x1 = loaded_data1.(first_var_name1);
loaded_data2 = load('X2_0_.mat');
variable_names2 = fieldnames(loaded_data2);
first_var_name2 = variable_names2{1};
x2 = loaded_data2.(first_var_name2);
L_order = 2; %高阶算子阶数
% 随机试验时间长度
data = load('Nk_11_13.mat');
fieldNames = fieldnames(data);
firstVarName = fieldNames{1};
Nk(1, 1:150) = data.(firstVarName)(1, 1:150); 
% 输出期望轨迹
for n_step = 0:120
    if n_step < 50
        y_d1(1, n_step+1) = 0.15*n_step*(1+sin(8*pi*n_step/100-pi/2));  %非线性期望输出1
        y_d2(1, n_step+1) = 2*log10(n_step/50)+2;
    else
        y_d1(1, n_step+1) = 0.05*n_step*(1+sin(8*pi*n_step/100-pi/2));  %非线性期望输出1
        y_d2(1, n_step+1) = 2*log10(n_step/50)+2;
    end
end
% 初始化历史控制量和误差
for k = 1:m
    t=0;
    

    decay_ratio = exp(-0.05 * (k - 1)); 
    
    A11 = 0; 
    A12 = 1.2 + 0.1 * decay_ratio;    % 从 1.3 逐渐趋近于定值 1.2
    A21 = 1.2 - 0.2 * decay_ratio;    % 从 1.0 逐渐趋近于定值 1.2
    A22 = 0;
    
    B11 = exp(-(t-1)/100 * (1 - 0.2 * decay_ratio)); % 指数内部系数从 0.8 趋近于 1.0
    B12 = 0; 
    B21 = 0; 
    B22 = 5 + (5.2 * cos(t) - 5) * decay_ratio; % 从 5.2*cos(t) 逐渐趋近于定值 5
    
    C1 = 0.15 * exp(-t/100); 
    C2 = (0.4 + 0.05 * decay_ratio) * exp(-t/100);   % 从 0.45 逐渐趋近于定值 0.4
    % ==============================================
    y1(k,1) = C1*x1(k,1);  %实际迭代输出1
    y2(k,1) = C2*x2(k,1);  %实际迭代输出2
    
    tk = 103; %这是一个1行150列的行向量，存储了每次迭代的时间步数
    
    % 短任务处理（tk<103）
    if tk < 103  
        for t = 2:tk
            x1(k,t) =A11*x1(k,t-1) +A12*sin(x2(k,t-1))+cos(t-1)+B11*u1(k,t-1)+B12*u2(k,t-1);
            x2(k,t) =A21*cos(x1(k,t-1))+A22*x2(k,t-1)+B21*u1(k,t-1)+B22*u2(k,t-1);
            y1(k,t) = C1 * x1(k,t);
            y2(k,t) = C1 * x2(k,t);
            % 误差计算
            e1(k, t) = y_d1(1, t) - y1(k, t);
            e2(k, t) = y_d2(1, t) - y2(k, t);
            e1(k, t+1) = y_d1(1, t+1) - C1*(A11*x1(k,t) +A12*sin(x2(k,t))+cos(t)+B11*u1(k,t)+B12*u2(k,t));
            e2(k, t+1) = y_d2(1, t+1) - C2*(A21*cos(x1(k,t))+A22*x2(k,t)+B21*u1(k,t)+B22*u2(k,t));
            e1_abs(k, t) = abs(e1(k, t));
            e2_abs(k, t) = abs(e2(k, t));
            
            % 控制律更新
            if t == tk
                e1_abs(k, t) = abs(e1(k, t));
                e2_abs(k, t) = abs(e2(k, t));
            end
            if k == 1
                u1(k+1, 1) = [1,0]*[u1(k, 1); u2(k, 1)]+ L11 * [e1(k, 2); e2(k, 2)];
                u2(k+1, 1) = [1,0]*[u1(k, 1); u2(k, 1)]+ L21 * [e1(k, 2); e2(k, 2)];
            else
                u1(k+1, 1) = W11*[u1(k, 1); u2(k, 1)] + W12*[u1(k-1, 1); u2(k-1, 1)] + L11 * [e1(k, 2); e2(k, 2)] + L12 * [e1(k-1, 2); e2(k-1, 2)];
                u2(k+1, 1) = W21*[u1(k, 1); u2(k, 1)] + W22*[u1(k-1, 1); u2(k-1, 1)] + L21 * [e1(k, 2); e2(k, 2)] + L22 * [e1(k-1, 2); e2(k-1, 2)];
            end
            if k == 1
                % 第一次迭代：控制量为0
                u1(k,t) = 0;
                u2(k,t) = 0;
            elseif k==2
                u1(k, t) = [1,0]*[u1(k-1, t); u2(k-1, t)] +  L11 * [e1(k-1, t+1); e2(k-1, t+1)];
                u2(k, t) = [1,0]*[u1(k-1, t); u2(k-1, t)] +  L21 * [e1(k-1, t+1); e2(k-1, t+1)]; 
            else
                u1(k, t) = W11*[u1(k-1, t); u2(k-1, t)] + W12*[u1(k-2, t); u2(k-2, t)] + L11 * [e1(k-1, t+1); e2(k-1, t+1)] + L12 * [e1(k-2, t+1); e2(k-2, t+1)];
                u2(k, t) = W21*[u1(k-1, t); u2(k-1, t)] + W22*[u1(k-2, t); u2(k-2, t)] + L21 * [e1(k-1, t+1); e2(k-1, t+1)] + L22 * [e1(k-2, t+1); e2(k-2, t+1)];
            end
        end
    else %tk>=103
        for t=2:103
            x1(k,t) =A11*x1(k,t-1) +A12*sin(x2(k,t-1))+cos(t-1)+B11*u1(k,t-1)+B12*u2(k,t-1);
            x2(k,t) =A21*cos(x1(k,t-1))+A22*x2(k,t-1)+B21*u1(k,t-1)+B22*u2(k,t-1);
            y1(k,t) = C1 * x1(k,t);
            y2(k,t) = C1 * x2(k,t);
            % 误差计算
            e1(k, t) = y_d1(1, t) - y1(k, t);
            e2(k, t) = y_d2(1, t) - y2(k, t);
            e1(k, t+1) = y_d1(1, t+1) - C1*(A11*x1(k,t) +A12*sin(x2(k,t))+cos(t)+B11*u1(k,t)+B12*u2(k,t));
            e2(k, t+1) = y_d2(1, t+1) - C2*(A21*cos(x1(k,t))+A22*x2(k,t)+B21*u1(k,t)+B22*u2(k,t));
            e1_abs(k, t) = abs(e1(k, t));
            e2_abs(k, t) = abs(e2(k, t));
            
            % u(k,1)的设定
            if k == 1
                u1(k+1, 1) = [1,0]*[u1(k, 1); u2(k, 1)]+ L11 * [e1(k, 2); e2(k, 2)];
                u2(k+1, 1) = [1,0]*[u1(k, 1); u2(k, 1)]+ L21 * [e1(k, 2); e2(k, 2)];
            else
                u1(k+1, 1) = W11*[u1(k, 1); u2(k, 1)] + W12*[u1(k-1, 1); u2(k-1, 1)] + L11 * [e1(k, 2); e2(k, 2)] + L12 * [e1(k-1, 2); e2(k-1, 2)];
                u2(k+1, 1) = W21*[u1(k, 1); u2(k, 1)] + W22*[u1(k-1, 1); u2(k-1, 1)] + L21 * [e1(k, 2); e2(k, 2)] + L22 * [e1(k-1, 2); e2(k-1, 2)];
            end
            if k == 1
                % 第一次迭代：控制量为0
                u1(k,t) = 0;
                u2(k,t) = 0;
            elseif k==2
                u1(k, t) = [1,0]*[u1(k-1, t); u2(k-1, t)] + L11 * [e1(k-1, t+1); e2(k-1, t+1)];
                u2(k, t) = [1,0]*[u1(k-1, t); u2(k-1, t)] + L21 * [e1(k-1, t+1); e2(k-1, t+1)];
            else
                u1(k, t) = W11*[u1(k-1, t); u2(k-1, t)] + W12*[u1(k-2, t); u2(k-2, t)] + L11 * [e1(k-1, t+1); e2(k-1, t+1)] + L12 * [e1(k-2, t+1); e2(k-2, t+1)];
                u2(k, t) = W21*[u1(k-1, t); u2(k-1, t)] + W22*[u1(k-2, t); u2(k-2, t)] + L21 * [e1(k-1, t+1); e2(k-1, t+1)] + L22 * [e1(k-2, t+1); e2(k-2, t+1)];
            end
        end
        for t=104:tk
            x1(k,t) =A11*x1(k,t-1) +A12*sin(x2(k,t-1))+cos(t-1)+B11*u1(k,t-1)+B12*u2(k,t-1);
            x2(k,t) =A21*cos(x1(k,t-1))+A22*x2(k,t-1)+B21*u1(k,t-1)+B22*u2(k,t-1);
            y1(k,t) = C1 * x1(k,t) ;
            y2(k,t) = C1 * x2(k,t) ;
            %误差（未修订）
            e1(k,t) = 0;
            e2(k,t) = 0;
            e1(k,t+1) = 0;
            e2(k,t+1) = 0;
            e1_abs(k, t) = abs(e1(k, t));
            e2_abs(k, t) = abs(e2(k, t));
            
            if t==tk
                e1_abs(k, t) = abs(e1(k, t));
                e2_abs(k, t) = abs(e2(k, t));
            end
            
            if k == 1
                u1(k+1, 1) = [1,0]*[u1(k, 1); u2(k, 1)]+ L11 * [e1(k, 2); e2(k, 2)];
                u2(k+1, 1) = [1,0]*[u1(k, 1); u2(k, 1)]+ L21 * [e1(k, 2); e2(k, 2)];
            else
                u1(k+1, 1) = W11*[u1(k, 1); u2(k, 1)] + W12*[u1(k-1, 1); u2(k-1, 1)] + L11 * [e1(k, 2); e2(k, 2)] + L12 * [e1(k-1, 2); e2(k-1, 2)];
                u2(k+1, 1) = W21*[u1(k, 1); u2(k, 1)] + W22*[u1(k-1, 1); u2(k-1, 1)] + L21 * [e1(k, 2); e2(k, 2)] + L22 * [e1(k-1, 2); e2(k-1, 2)];
            end
            if k == 1
                u1(k,t) = 0;
                u2(k,t) = 0;
            elseif k==2
                u1(k, t) = [1,0]*[u1(k-1, t); u2(k-1, t)] + L12 * [e1(k-1, t+1); e2(k-1, t+1)];
                u2(k, t) = [1,0]*[u1(k-1, t); u2(k-1, t)] + L21 * [e1(k-1, t+1); e2(k-1, t+1)];
            else
                u1(k, t) = W11*[u1(k-1, t); u2(k-1, t)] + W12*[u1(k-2, t); u2(k-2, t)] + L11 * [e1(k-1, t+1); e2(k-1, t+1)] + L12 * [e1(k-2, t+1); e2(k-2, t+1)];
                u2(k, t) = W21*[u1(k-1, t); u2(k-1, t)] + W22*[u1(k-2, t); u2(k-2, t)] + L21 * [e1(k-1, t+1); e2(k-1, t+1)] + L22 * [e1(k-2, t+1); e2(k-2, t+1)];
            end
        end
    end
end
for i = 1:100
    for t = 1:120
        e1_sum(1, i) = e1_sum(1, i) + e1_abs(i, t);
        e2_sum(1, i) = e2_sum(1, i) + e2_abs(i, t);
        
    end
end

%% Figure 1: Output Tracking
figure(1);
set(gcf, 'Color', 'w'); % 设置纯白背景

subplot(2, 1, 1);
plot(0:99, y_d1(1:100), 'k', 'LineWidth', 1.5); hold on;
plot(0:Nk(6)-1, y1(6, 1:Nk(6)), 'Color', [1, 0, 0], 'LineWidth', 1.5, 'LineStyle', '--'); hold on;
plot(0:Nk(11)-1, y1(11, 1:Nk(11)), 'Color', [0, 1, 0], 'LineWidth', 1.5, 'LineStyle', ':'); hold on;
legend({'y_d^{(1)}(m)', 'y^{(1)}_{6}(m)', 'y^{(1)}_{11}(m)'}, ...
    'FontName', 'Times New Roman', 'Location', 'northwest'); 
xlabel('Time m', 'FontName', 'Times New Roman');
ylabel('Output', 'FontName', 'Times New Roman');
set(gca, 'LineWidth', 1.2, 'FontName', 'Times New Roman'); 
xlim([0, 110]);
box on;
grid off; % 去除网格

subplot(2, 1, 2);
plot(0:99, y_d2(3:102), 'k', 'LineWidth', 1.5); hold on;
plot(0:Nk(6)-1, y2(6, 1:Nk(6)), 'Color', [1, 0, 0], 'LineWidth', 1.5, 'LineStyle', '--'); hold on;
plot(0:Nk(11)-1, y2(11, 2:Nk(11)+1), 'Color', [0, 1, 0], 'LineWidth', 1.5, 'LineStyle', ':'); hold on;
legend({'y_d^{(2)}(m)', 'y^{(2)}_{6}(m)', 'y^{(2)}_{11}(m)'}, ...
    'FontName', 'Times New Roman', 'Location', 'southeast'); 
xlabel('Time m', 'FontName', 'Times New Roman');
ylabel('Output', 'FontName', 'Times New Roman');
set(gca, 'LineWidth', 1.2, 'FontName', 'Times New Roman'); 
xlim([0, 110]);
box on;
grid off; % 去除网格

% 放大纵轴范围
current_ylim = ylim; 
y_range = current_ylim(2) - current_ylim(1);
ylim([current_ylim(1), current_ylim(2) + y_range * 0.15]);

%% Figure 2: Tracking Error (CE)
figure(2);
set(gcf, 'Color', 'w'); % 设置纯白背景
subplot(2, 1, 1);
plot(0:99, e1_sum(1:100), '-', 'Color', [1, 0, 0], 'LineWidth', 1.5); hold on;
xlabel('Iteration l', 'FontName', 'Times New Roman');
ylabel('CE^{(1)}_l', 'FontName', 'Times New Roman');
set(gca, 'LineWidth', 1.2, 'FontName', 'Times New Roman'); 
xlim([0, 100]);
box on;
grid off;

subplot(2, 1, 2);
plot(0:99, e2_sum(1:100), '-', 'Color', [1, 0, 0], 'LineWidth', 1.5); hold on;
xlabel('Iteration l', 'FontName', 'Times New Roman');
ylabel('CE^{(2)}_l', 'FontName', 'Times New Roman');
set(gca, 'LineWidth', 1.2, 'FontName', 'Times New Roman'); 
xlim([0, 100]);
ylim([0, 250]);
box on;
grid off;

%% Figure 3: Input State (x)
figure(3);
set(gcf, 'Color', 'w'); % 设置纯白背景
subplot(2, 1, 1);
plot(0:99, x1(1:100, 1), 'ks-', 'LineWidth', 1.0, 'MarkerSize', 5, ...
     'MarkerFaceColor', 'none', 'MarkerEdgeColor', 'k'); hold on;
xlabel('Iteration l', 'FontName', 'Times New Roman');
ylabel('x^{(1)}_l(0)', 'FontName', 'Times New Roman');
set(gca, 'LineWidth', 1.2, 'FontName', 'Times New Roman'); 
xlim([0, 100]);
box on;
grid off;

subplot(2, 1, 2);
plot(0:99, x2(1:100, 1), 'ks-', 'LineWidth', 1.0, 'MarkerSize', 5, ...
     'MarkerFaceColor', 'none', 'MarkerEdgeColor', 'k'); hold on;
xlabel('Iteration l', 'FontName', 'Times New Roman');
ylabel('x^{(2)}_l(0)', 'FontName', 'Times New Roman');
set(gca, 'LineWidth', 1.2, 'FontName', 'Times New Roman'); 
xlim([0, 100]);
box on;
grid off;

%% Figure 4: Trial Lengths (Nk)
figure(4);
set(gcf, 'Color', 'w'); % 设置纯白背景
plot(0:99, Nk(1:100), 'ks-', 'LineWidth', 1.0, 'MarkerSize', 5, ...
     'MarkerFaceColor', 'none', 'MarkerEdgeColor', 'k'); hold on;
xlabel('Iteration l', 'FontName', 'Times New Roman');
ylabel('Trial Lengths', 'FontName', 'Times New Roman');
set(gca, 'LineWidth', 1.2, 'FontName', 'Times New Roman'); 
xlim([0, 100]);
box on;
grid off;