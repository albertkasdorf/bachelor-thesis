clear; clc; close all;
format short; format compact;

% Dateiname
filename = 'los.csv';
%filename = 'nlos_water.csv';
%filename = 'nlos_metal.csv';
%filename = 'nlos_metal2.csv';

% Daten einlesen
data = dlmread(filename, ';', 1, 0);
data_count = size(data, 1);

% Spalten-Identifier
cid_r = 6;
cid_gt = 13;

% Figure
figure('DefaultAxesFontSize', 22, 'Pos', [100 100 1600 900]);

x = (1:data_count)';
y_gt = data(:, cid_gt);
y_r = data(:, cid_r);
plot(x, y_gt, '.b', x, y_r, '.r');

grid on; grid minor;
xlim([1 data_count]); ylim([1 12]);
xticks(1:500:data_count); yticks(1:1:12);
xtickangle(45);
xlabel('Messungen'); ylabel('Entfernung [m]');
legend('Tatsächliche Entfernung', 'Gemessene Entfernung', 'Location','southeast');

% Save Figure with Minimal White Space
% https://de.mathworks.com/help/matlab/creating_plots/save-figure-with-minimal-white-space.html
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

% Save figure
[file_path, file_name, file_ext] = fileparts(filename);
file_saveas = fullfile(file_path, ['entfernungsmessung_2018_01_20_' file_name]);
saveas(gcf, file_saveas, 'png');






