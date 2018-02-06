close all; clear;
%clc;
format long; format compact;

% Globale Variablen
global cid_time; global cid_x; global cid_y;

%
cid_time = 1;
cid_x = 4;
cid_y = 5;

%
source_file_name = 'Record_2017-12-18-11-53-54';
pt_file_name = strcat(source_file_name, '_pt.csv');
pe_file_name = strcat(source_file_name, '_pe.csv');

% Daten einlesen
data_pt = dlmread(pt_file_name, ';', 1, 0);
data_pe = dlmread(pe_file_name, ';', 1, 0);


%[mean_xyr, std_xyr] = mean_std_of_all_xyr(data_pt, data_pe);
%[mean_xyr, std_xyr] = mean_std_of_some_xyr(data_pt, data_pe);

%viz_one(data_pt, data_pe);
viz_some(data_pt, data_pe);


function viz_one(pose_trajectory, pose_estimation)
	global cid_time; global cid_x; global cid_y;

	% Kartenparameter
	map_resolution = 0.02;
	map_size = [1024 1024];
	map_center = (map_size * map_resolution) / 2;
	
	% Bild des OccupanyGrid laden, normalisieren und invertieren.
	map_image = imread('map.pgm');
	map_image = 1 - (map_image / 255);

	% Karte anzeigen
	map = robotics.OccupancyGrid(map_image, 1 / map_resolution);
	show(map);
	hold on;
	grid on; grid minor;
	axis equal;
	
	% Position und Partikel bestimmen
	ROWS = size(unique(pose_trajectory(:, cid_time)), 1);
	
	idx = 200;
	pose_time = pose_trajectory(idx, cid_time);
	pose_tra_xy = pose_trajectory(idx, [cid_x, cid_y]);
	pose_tra_xy = pose_tra_xy + map_center;
	
	selector = pose_estimation(:, cid_time) == pose_time;
	pose_est_xy = pose_estimation(selector, [cid_x, cid_y]);
	pose_est_xy = pose_est_xy + map_center;
	
	% Position und Partikel eintragen
	plot(pose_tra_xy(:,1), pose_tra_xy(:,2), 'gp', 'MarkerSize', 10 );
	plot(pose_est_xy(:,1), pose_est_xy(:,2), 'r+', 'MarkerSize', 10 );
	
	% Zoom into Figure
	xlim([9 16]);
	ylim([9 12]);
end

function viz_some(pose_trajectory, pose_estimation)
	global cid_time; global cid_x; global cid_y;

	% Kartenparameter
	map_resolution = 0.02;
	map_size = [1024 1024];
	map_center = (map_size * map_resolution) / 2;
	
	% Bild des OccupanyGrid laden, normalisieren und invertieren.
	map_image = imread('map.pgm');
	map_image = 1 - (map_image / 255);

	% Karte anzeigen
	map = robotics.OccupancyGrid(map_image, 1 / map_resolution);
	show(map);
	hold on;
	grid on; grid minor;
	axis equal;
	
	% Position und Partikel bestimmen
	SAMPLES = 10;
	ROWS = size(unique(pose_trajectory(:, cid_time)), 1);
		
	for idx_time = round(linspace(1, ROWS, SAMPLES))
		
		pose_time = pose_trajectory(idx_time, cid_time);
		pose_tra_xy = pose_trajectory(idx_time, [cid_x, cid_y]);
		pose_tra_xy = pose_tra_xy + map_center;
		
		selector = pose_estimation(:, cid_time) == pose_time;
		pose_est_xy = pose_estimation(selector, [cid_x, cid_y]);
		pose_est_xy = pose_est_xy + map_center;
		
		% Position und Partikel eintragen
		plot(pose_tra_xy(:,1), pose_tra_xy(:,2), 'gp', 'MarkerSize', 10 );
		plot(pose_est_xy(:,1), pose_est_xy(:,2), 'r+', 'MarkerSize', 10 );
		plot([pose_tra_xy(1); pose_est_xy(1, 1)], [pose_tra_xy(2); pose_est_xy(1, 2)], 'b:');
		
	end
		
	% Zoom into Figure
	xlim([9 16]);
	ylim([9 12]);
	
	% Legende
	legend('1x Position Odometrie','10x Position Partikel Filter', 'Location', 'northwest' );

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



