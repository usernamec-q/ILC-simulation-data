clc;clear;close all;
rA=unifrnd(0,4,4,1);
rE=unifrnd(-2,0,6,1);

rB(1:70,1)=1;

rC(1:70,1)=1;

rD=[rA;rB;rC;rE];

x3(1:150,1)=rD(randperm(numel(rD)));

figure
plot(0:99,x3(1:100, 1), 'ks-', 'LineWidth', 1); hold on;
xlabel('Iteration l');
ylabel('x^{(1)}_l(0)');
ax = gca;
box(ax, 'on');
ax.TickDir = 'in';
ax.YAxisLocation = 'left';
ax.FontName = 'Times New Roman';
ax.FontWeight = 'normal';
ax.FontSize = 13;
ax.LineWidth = 1.5; % 【修改】加粗边框
xlim([0, 100]);