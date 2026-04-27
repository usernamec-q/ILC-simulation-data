%% 清除工作空间
clear; clc; close all;

%% 1. 数据准备 (生成 150x55, [-0.4, 0.4] 随机干扰数据)
Data = cell(1, 4); 
rows = 150;      % Iteration
cols = 55;       % Time
min_val = -0.4;
max_val = 0.4;

for k = 1:4
    % 生成随机数据
    Data{k} = min_val + (max_val - min_val) * rand(rows, cols);
end

plot_titles = {
    'External load \omega_l^{(1)}', ...
    'Measurement noise v_l^{(1)}', ...
    'External load \omega_l^{(2)}', ...
    'Measurement noise v_l^{(2)}'
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
    
    set(gca, 'FontName', 'Times New Roman', ...
             'FontSize', 11, ...
             'FontWeight', 'normal', ...
             'FontAngle', 'normal'); 
    
    % 轴限制设置
    xlim([-2, dim_time]); 
    ylim([-2, dim_iter]); 
    
    % 【关键修改 1】：扩展 Z 轴范围
    % 原本数据最低是 -0.4，我们设置底限为 -0.45
    % 这样 -0.4 的刻度就会从底部“浮”起来，不再和 Iteration 的 150 重叠
    zlim([-0.45, 0.45]);
    
    % 【关键修改 2】：手动固定 Z 轴刻度，保持整洁
    zticks([-0.4, -0.2, 0, 0.2, 0.4]);
    
    % X 和 Y 轴刻度设置
    xticks([0, 10, 20, 30, 40, 55]);
    yticks([0, 50, 100, 150]);
    
    % 强制坐标轴刻度数字“竖直/正立”
    ax = gca;
    ax.XAxis.TickLabelRotation = 0; 
    ax.YAxis.TickLabelRotation = 0; 
    
    set(gca, 'TickDir', 'out'); 
    
    % --- 数字位置优化 ---
    set(gca, 'TickLength', [0.005, 0.005]); 
    % 使用底层 Ruler 属性强制减少数字与轴的间隙
    ax.XRuler.TickLabelGapOffset = -2; 
    ax.YRuler.TickLabelGapOffset = -2;
    % Z轴保持默认或稍微推远一点点，防止太挤（这里设为0即可，主要靠zlim拉开距离）
    ax.ZRuler.TickLabelGapOffset = 0; 
    
    light('Position', [-1, -1, 1], 'Style', 'infinite');
    material('dull');
    
    % 标题
    title(plot_titles{k}, 'Interpreter', 'tex', ...
        'FontName', 'Times New Roman', ... 
        'FontSize', 14, ...
        'FontWeight', 'normal', ...
        'FontAngle', 'normal'); 
        
    % --- Colorbar ---
    pos = get(gca, 'Position'); 
    set(gca, 'Position', [pos(1), pos(2), pos(3)*0.85, pos(4)]); 
    pos_new = get(gca, 'Position');
    
    c = colorbar;
    c.Position = [pos_new(1) + pos_new(3) + 0.02, pos_new(2) + 0.1, 0.015, pos_new(4)*0.6];
    c.Label.String = ''; 
    
    % --- 坐标轴标签位置优化 ---
    xlabel(''); ylabel(''); zlabel(''); 
    
    z_min = min(min(current_data)); 
    z_base = min(zlim) - (max(zlim)-min(zlim))*0.06; 
    
    % --- 文字位置优化 ---
    offset_scale = 0.18; 
    
    % 1. 右侧轴 (Time n)
    x_mid = dim_time / 2; 
    y_pos_x = 0 - (dim_iter) * offset_scale; 
    
    t_time = text(x_mid, y_pos_x, z_base, 'Time n');
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