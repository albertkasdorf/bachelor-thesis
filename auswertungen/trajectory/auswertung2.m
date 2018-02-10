%
% Berechnen der Differenz zwischen Map und Robotino/LSM/RF2O zu jedem
% Zeitpunkt.
%
close all; clear; clc;
format long; format compact;

% Konstanten
cid_time = 1;
cid_sec = 2;
cid_x = 4;
cid_y = 5;

% Dateipfad
%file_name = 'Record_2018-02-08-12-30-43';
file_name = 'Record_2018-02-08-12-33-53';
%file_name = 'Record_2018-02-08-13-09-17';

robo_file_name = strcat(file_name, '_odom_robotino.csv');
lsm_file_name = strcat(file_name, '_odom_lsm.csv');
rf2o_file_name = strcat(file_name, '_odom_rf2o.csv');
map_file_name = strcat(file_name, '_map_robotino.csv');

%
robo = dlmread(robo_file_name, ';', 1, 0);
lsm = dlmread(lsm_file_name, ';', 1, 0);
rf2o = dlmread(rf2o_file_name, ';', 1, 0);
map = dlmread(map_file_name, ';', 1, 0);

% Zeit korrigieren
robo = robo(:, :) + [0 -robo(1, cid_sec) 0 0 0 0 0 0 0 0];
lsm = lsm(:, :) + [0 -lsm(1, cid_sec) 0 0 0 0 0 0 0 0];
rf2o = rf2o(:, :) + [0 -rf2o(1, cid_sec) 0 0 0 0 0 0 0 0];
map = map(:, :) + [0 -map(1, cid_sec) 0 0 0 0 0 0 0 0];

%
unique_times = unique(map(:, cid_sec));

diff = [];

%
for t = 1:size(unique_times, 1)
	
	%
	time = unique_times(t);
	
	%
	selector = map(:, cid_sec) == time;
	map_mean = [mean(map(selector, cid_x)) mean(map(selector, cid_y))];
	
	%
	selector = robo(:, cid_sec) == time;
	robo_mean = [mean(robo(selector, cid_x)) mean(robo(selector, cid_y))];
	robo_diff = abs(map_mean - robo_mean);
	robo_range = sqrt((map_mean(1) - robo_mean(1)) ^ 2 + (map_mean(2) - robo_mean(2)) ^ 2 );
	
	%
	selector = lsm(:, cid_sec) == time;
	lsm_mean = [mean(lsm(selector, cid_x)) mean(lsm(selector, cid_y))];
	lsm_diff = abs(map_mean - lsm_mean);
	lsm_range = sqrt((map_mean(1) - lsm_mean(1)) ^ 2 + (map_mean(2) - lsm_mean(2)) ^ 2 );
	
	%
	selector = rf2o(:, cid_sec) == time;
	rf2o_mean = [mean(rf2o(selector, cid_x)) mean(rf2o(selector, cid_y))];
	rf2o_diff = abs(map_mean - rf2o_mean);
	rf2o_range = sqrt((map_mean(1) - rf2o_mean(1)) ^ 2 + (map_mean(2) - rf2o_mean(2)) ^ 2 );
	
	%
	diff = [
		diff;
		time robo_range lsm_range rf2o_range robo_diff lsm_diff rf2o_diff
	];
	
end

data = diff(:, 2);
data_stat = [
	mean(data) std(data), std(data) / sqrt(size(data, 1)) min(data) max(data)];
data = diff(:, 3);
data_stat = [data_stat;
	mean(data) std(data), std(data) / sqrt(size(data, 1)) min(data) max(data)];
data = diff(:, 4);
data_stat = [data_stat;
	mean(data) std(data), std(data) / sqrt(size(data, 1)) min(data) max(data)];

fprintf('\\hline\n');
fprintf('Verfahren & $\\overline{x}$ & $\\sigma$ & $SE_{\\overline{x}}$ & Min & Max \\\\\n');
fprintf(' & [\\si{\\meter}] & [\\si{\\meter}] & [\\si{\\meter}] & [\\si{\\meter}] & [\\si{\\meter}] \\\\\n');
fprintf('\\hline\n');
fprintf('\\hline\n');
fprintf('Verfahrensname & \\num{%.3f} & \\num{%.3f} & \\num{%.3f} & \\num{%.3f} & \\num{%.3f} \\\\\n', data_stat');
fprintf('\\hline\n');





