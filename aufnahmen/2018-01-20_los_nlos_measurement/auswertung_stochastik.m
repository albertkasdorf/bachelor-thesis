clear; clc; close all;
format short; format compact;

% Dateiname
filename = 'los.csv';
filename = 'nlos_water.csv';
filename = 'nlos_metal.csv';
filename = 'nlos_metal2.csv';

% Daten einlesen
data = dlmread(filename, ';', 1, 0);

% Spalten-Identifier
cid_r = 6;
cid_gt = 13;

gt_values = unique(data(:, cid_gt));
gt_values_count = size(gt_values, 1);

data_count = size(data, 1);
data_stat = zeros([gt_values_count 7]);

for i = 1:gt_values_count
    
    gt_value = gt_values(i);
    data_selector = logical(data(:, cid_gt) == gt_value);
    data_selected = data(data_selector, cid_r);
    
    r_mean = mean(data_selected);
    r_std = std(data_selected);
    r_sem = std(data_selected) / sqrt(size(data_selected, 1));
    r_min = min(data_selected);
    r_max = max(data_selected);
    r_bias = abs(gt_value - r_mean);
    
    data_stat(i,:) = [gt_value r_mean r_std r_sem r_min r_max r_bias];
end

data_stat;

% x = (1:data_count)';
% y_gt = data(:, cid_gt);
% y_r = data(:, cid_r);
% figure('DefaultAxesFontSize', 14);
% plot(x, y_gt, '.g', x, y_r, '.r');
% grid on;
% grid minor;
% xlim([1 data_count]);
% ylim([1 12]);
%legend('range', 'ground\_truth', 'Location','northwest');

fprintf('\\hline\n');
fprintf('Entfernung [\\si{\\meter}] & $\\overline{x}$ & $\\sigma$ & $SE_{\\overline{x}}$ & Min & Max & Bias \\\\\n');
fprintf('\\hline\n');
fprintf('\\hline\n');
fprintf('\\num{%.1f} & \\num{%.3f} & \\num{%.3f} & \\num{%.4f} & \\num{%.3f} & \\num{%.3f} & \\num{%.3f} \\\\\n', data_stat');
fprintf('\\hline\n');

