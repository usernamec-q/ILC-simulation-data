%% 清除工作空间
clear; clc; close all;

%% 1. 数据准备 (100x120)
Data = cell(1, 4); 
rows = 100;      % Iteration (迭代次数)
cols = 120;      % Time (时间长度)
min_val = -0.4;
max_val = 0.4;

for k = 1:4
    Data{k} = min_val + (max_val - min_val) * rand(rows, cols);
end

% --- 修改点：在标题公式中添加 (n) ---
plot_titles = {
    'External load $\phi_l^{(1)}(m)$', ...        
    'Measurement noise $\varphi_l^{(1)}(m)$', ... 
    'External load $\phi_l^{(2)}(m)$', ...        
    'Measurement noise $\varphi_l^{(2)}(m)$'      
};

%% 2. 绘图配色参数
scientific_colormap = [0.0, 0.0, 0.5; 0.0, 0.0, 0.8; 0.0, 0.2, 0.9; 0.0, 0.5, 1.0; 
                       0.2, 0.8, 1.0; 0.5, 0.9, 0.9; 0.8, 1.0, 0.8; 1.0, 1.0, 0.6; 
                       1.0, 0.9, 0.4; 1.0, 0.7, 0.2; 1.0, 0.5, 0.0; 1.0, 0.3, 0.0; 
                       0.9, 0.1, 0.0; 0.7, 0.0, 0.0; 0.5, 0.0, 0.0];

figure('Position', [50, 50, 1200, 900], 'Color', [1 1 1]);

%% 3. 循环绘制
for k = 1:4
    subplot(2, 2, k);
    
    current_data = Data{k}; 
    [dim_iter, dim_time] = size(current_data); 
    
    % 网格生成
    [x_time, y_iter] = meshgrid(0:dim_time-1, 0:dim_iter-1);
    
    % --- 绘图 ---
    hSurf = surf(x_time, y_iter, current_data);
    
    set(hSurf, ...
        'EdgeColor', 'interp', ... 
        'FaceAlpha', 0.9, ...
        'FaceLighting', 'gouraud', ...
        'LineWidth', 0.1);          
     
    colormap(scientific_colormap);
    
    % --- 视角与坐标轴设置 ---
    view(-45, 30); 
    grid on; 
    set(gca, 'Box', 'off'); 
    
    % 设置坐标轴字体
    set(gca, 'FontName', 'Times New Roman', ...
             'FontSize', 11, ...
             'FontWeight', 'normal', ...
             'FontAngle', 'normal'); 
    
    % 轴限制设置
    xlim([-2, dim_time]); 
    ylim([-2, dim_iter]); 
    zlim([-0.45, 0.45]);
    zticks([-0.4, -0.2, 0, 0.2, 0.4]); 
    
    % 刻度设置
    xticks([0, 20, 40, 60, 80, 100, 120]);
    yticks([0, 25, 50, 75, 100]);
    
    ax = gca;
    ax.XAxis.TickLabelRotation = 0; 
    ax.YAxis.TickLabelRotation = 0; 
    
    set(gca, 'TickDir', 'out'); 
    set(gca, 'TickLength', [0.005, 0.005]); 
    ax.XRuler.TickLabelGapOffset = -2; 
    ax.YRuler.TickLabelGapOffset = -2;
    ax.ZRuler.TickLabelGapOffset = 0; 
    
    light('Position', [-1, -1, 1], 'Style', 'infinite');
    material('dull');
    
    % --- 标题 (安全赋值方式) ---
    % 1. 先创建一个空标题
    hTitle = title('', 'FontName', 'Times New Roman', ... 
        'FontSize', 14, ...
        'FontWeight', 'normal', ...
        'FontAngle', 'normal');
    % 2. 显式设置解释器为 latex
    set(hTitle, 'Interpreter', 'latex');
    % 3. 最后再赋值字符串
    set(hTitle, 'String', plot_titles{k});
        
    % --- Colorbar ---
    pos = get(gca, 'Position'); 
    set(gca, 'Position', [pos(1), pos(2), pos(3)*0.85, pos(4)]); 
    pos_new = get(gca, 'Position');
    
    c = colorbar;
    c.Position = [pos_new(1) + pos_new(3) + 0.02, pos_new(2) + 0.1, 0.015, pos_new(4)*0.6];
    c.Label.String = ''; 
    % 为了防止 Colorbar 标签也触发类似错误，显式设置它的解释器
    set(c.Label, 'Interpreter', 'latex'); 
    
    xlabel(''); ylabel(''); zlabel(''); 
    
    z_min = min(min(current_data)); 
    z_base = min(zlim) - (max(zlim)-min(zlim))*0.06; 
    
    % --- 文字位置优化 ---
    offset_scale = 0.18; 
    
    % 1. 右侧轴 (Time n)
    x_mid = dim_time / 2; 
    y_pos_x = 0 - (dim_iter) * offset_scale; 
    
    t_time = text(x_mid, y_pos_x, z_base, 'Time m');
    set(t_time, ...
        'FontName', 'Times New Roman', ... 
        'FontSize', 13, ...
        'FontWeight', 'normal', ...        
        'FontAngle', 'normal', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'top', ...
        'Rotation', 33); 
        
    % 2. 左侧轴 (Iteration l)
    y_mid = dim_iter / 2; 
    x_pos_y = 0 - (dim_time) * offset_scale; 
    
    t_iter = text(x_pos_y, y_mid, z_base, 'Iteration l');
    set(t_iter, ...
        'FontName', 'Times New Roman', ... 
        'FontSize', 13, ...
        'FontWeight', 'normal', ...       
        'FontAngle', 'normal', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'top', ... 
        'Rotation', -23); 
end