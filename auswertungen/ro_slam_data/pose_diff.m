close all; clear; clc;
format long; format compact;

% Globale Variablen
global cid_time; global cid_x; global cid_y;

%
cid_time = 1;
cid_x = 4;
cid_y = 5;

% Kartenparameter
map_resolution = 0.02;
map_size = [1024 1024];
map_center = (map_size * map_resolution) / 2;

%
%file_name_source = 'Record_2017-12-18-11-53-54';
file_name_source = 'Record_2018-02-08-12-33-53_filtered';
file_name_number = '_21';
file_name_pt = strcat(file_name_source, file_name_number, '_pt.csv');
file_name_pe = strcat(file_name_source, file_name_number, '_pe.csv');
file_name_map = strcat(file_name_source, '.pgm');

% Daten einlesen
data_pt = dlmread(file_name_pt, ';', 1, 0);
data_pe = dlmread(file_name_pe, ';', 1, 0);

% Positionen korrigieren
data_pt = data_pt(:, :) + [0 0 0 map_center(1) map_center(2) 0 0 0 0 0];
data_pe = data_pe(:, :) + [0 0 0 map_center(1) map_center(2) 0 0 0 0 0];

% Bild des OccupanyGrid laden, normalisieren und invertieren.
data_map = imread(file_name_map);
data_map = 1 - (data_map / 255);
occupancy_grid = robotics.OccupancyGrid(data_map, 1 / map_resolution);



%[mean_xyr, std_xyr] = mean_std_of_all_xyr(data_pt, data_pe);
%[mean_xyr, std_xyr] = mean_std_of_some_xyr(data_pt, data_pe);

%viz_one(data_pt, data_pe, occupancy_grid);
%viz_some(data_pt, data_pe, occupancy_grid);
viz_trajectory(data_pt, data_pe, occupancy_grid);


file_name = strcat(file_name_source, file_name_number);
[file_path, file_name, file_ext] = fileparts(file_name);
file_saveas = fullfile(file_path, [file_name '_trajectory_pf']);
saveas(gcf, file_saveas, 'png');


function viz_trajectory(pose_trajectory, pose_estimation, occupancy_grid)
	
	%
	show(occupancy_grid);
	hold on; grid on; grid minor;
	title('Virtuelle UWB Module');
	xlabel('X [m]');
	ylabel('Y [m]');
	
	% Ground Truth Trajectory
	plot(pose_trajectory(:, cid.x), pose_trajectory(:, cid.y), 'b-', 'DisplayName', 'Ground Truth Trajektorie');
	
	% Particle Filter Trajectory
	plot(pose_estimation(:, cid.x), pose_estimation(:, cid.y), 'r.', 'DisplayName', 'Positionsschätzung des RO-SLAM');
	
	%
	%axis equal;
	xlim([9 16]);
	ylim([8 13]);
	legend('Location', 'southeast');
end

function viz_some(pose_trajectory, pose_estimation, occupancy_grid)
	
	% Karte anzeigen
	show(occupancy_grid);
	hold on;
	grid on; grid minor;
	axis equal;
	
	% Position und Partikel bestimmen
	SAMPLES = 50;
	ROWS = size(unique(pose_trajectory(:, cid.time)), 1);
		
	for idx_time = round(linspace(1, ROWS, SAMPLES))
		
		pose_time = pose_trajectory(idx_time, cid.time);
		pose_tra_xy = pose_trajectory(idx_time, [cid.x, cid.y]);
		
		selector = pose_estimation(:, cid.time) == pose_time;
		pose_est_xy = pose_estimation(selector, [cid.x, cid.y]);
		
		% Position und Partikel eintragen
		plot(pose_tra_xy(:,1), pose_tra_xy(:,2), 'gp', 'MarkerSize', 10 );
		plot(pose_est_xy(:,1), pose_est_xy(:,2), 'r+', 'MarkerSize', 10 );
		plot([pose_tra_xy(1); pose_est_xy(1, 1)], [pose_tra_xy(2); pose_est_xy(1, 2)], 'b:');
		
	end
	
	% Trajektorie einzeichen
	plot(pose_trajectory(:, cid.x), pose_trajectory(:, cid.y), 'm-');
		
	% Zoom into Figure
	xlim([9 16]);
	ylim([8 13]);
	
	% Legende
	legend('1x Position Odometrie','10x Position Partikel Filter', 'Location', 'northwest' );

end

function viz_one(pose_trajectory, pose_estimation, occupancy_grid)
	
	% Karte anzeigen
	show(occupancy_grid);
	hold on;
	grid on; grid minor;
	axis equal;
	
	% Position und Partikel bestimmen
	ROWS = size(unique(pose_trajectory(:, cid.time)), 1);
	
	idx = 200;
	pose_time = pose_trajectory(idx, cid.time);
	pose_tra_xy = pose_trajectory(idx, [cid.x, cid.y]);
	
	selector = pose_estimation(:, cid.time) == pose_time;
	pose_est_xy = pose_estimation(selector, [cid.x, cid.y]);
	
	% Position und Partikel eintragen
	plot(pose_tra_xy(:,1), pose_tra_xy(:,2), 'gp', 'MarkerSize', 10 );
	plot(pose_est_xy(:,1), pose_est_xy(:,2), 'r+', 'MarkerSize', 10 );
	
	% Zoom into Figure
	xlim([9 16]);
	ylim([9 12]);
end


function [mean_xyr, std_xyr] = mean_std_of_some_xyr(pose_trajectory, pose_estimation)
	global cid_time; global cid_x; global cid_y;
	
	SAMPLES = 10;
	ROWS = size(unique(pose_trajectory(:, cid_time)), 1);
	
	mean_xyr = [];
	std_xyr = [];
	
	for idx_time = round(linspace(1, ROWS, SAMPLES))
		
		pose_time = pose_trajectory(idx_time, cid_time);
		pose_tra_xy = pose_trajectory(idx_time, [cid_x, cid_y]);
		
		selector = pose_estimation(:, cid_time) == pose_time;
		pose_est_xy = pose_estimation(selector, [cid_x, cid_y]);
		
		pose_dif_xy = pose_est_xy - pose_tra_xy;
		pose_r = sqrt(pose_dif_xy(:,1) .^ 2 + pose_dif_xy(:,2) .^ 2);
		
		mean_xyr = [mean_xyr; mean(pose_dif_xy) mean(pose_r)];
		std_xyr = [std_xyr; std(pose_dif_xy) std(pose_r)];
		
	end
	
end


function [mean_xyr, std_xyr] = mean_std_of_all_xyr(pose_trajectory, pose_estimation)
	global cid_time; global cid_x; global cid_y;
	
	ROWS = size(unique(pose_trajectory(:, cid_time)), 1);
	pose_alldiff = [];
	
	for i = 1:ROWS
		
		pose_time = pose_trajectory(i, cid_time);
		pose_trj_xy = pose_trajectory(i, [cid_x cid_y]);
		
		selector = pose_estimation(:, cid_time) == pose_time;
		pose_est_xy = pose_estimation(selector, [cid_x cid_y]);
		
		pose_diff_xy = pose_est_xy - pose_trj_xy;
		
		pose_alldiff = [pose_alldiff; pose_diff_xy];
	end
	
	mean_xy = mean(pose_alldiff);
	std_xy = std(pose_alldiff);
	
	pose_range = sqrt(pose_alldiff(:,1) .^ 2 + pose_alldiff(:,2) .^ 2);
	
	mean_range = mean(pose_range);
	std_range = std(pose_range);
	
	mean_xyr = [mean_xy mean_range];
	std_xyr = [std_xy std_range];
end



