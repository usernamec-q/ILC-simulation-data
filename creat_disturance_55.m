clear; clc; close all;
% 1. 设置参数
rows = 150;          % 行数
cols = 55;          % 列数
min_val = -0.4;      % 下界
max_val = 0.4;       % 上界

% 2. 生成数据
% rand() 生成的是 (0,1) 之间的数据
% 公式: result = min + (max - min) * rand()
interference_data = min_val + (max_val - min_val) * rand(rows, cols);

