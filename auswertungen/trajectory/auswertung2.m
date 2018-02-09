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
odom_file_name = 'Record_2018-02-08-12-30-43_odom';
odom_file_name = 'Record_2018-02-08-12-33-53_odom';
map_file_name = 'Record_2018-02-08-12-30-43_map';
map_file_name = 'Record_2018-02-08-12-33-53_map';

robo_file_name = strcat(odom_file_name, '_robotino.csv');
lsm_file_name = strcat(odom_file_name, '_lsm.csv');
rf2o_file_name = strcat(odom_file_name, '_rf2o.csv');
map_file_name = strcat(map_file_name, '_robotino.csv');

%
robo = dlmread(robo_file_name, ';', 1, 0);
lsm = dlmread(lsm_file_name, ';', 1, 0);
rf2o = dlmread(rf2o_file_name, ';', 1, 0);
map = dlmread(map_file_name, ';', 1, 0);

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






