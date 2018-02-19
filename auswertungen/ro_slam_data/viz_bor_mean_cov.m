close all; clear; %clc;
format long; format compact;

% Globale Variablen

% Konstanten
	
% Dateipfad
file_name_source = 'Record_2018-02-08-12-33-53_filtered';
file_name_number = '_5';
file_name_source_number = strcat(file_name_source, file_name_number);
file_name_pt = strcat(file_name_source, file_name_number, '_pt.csv');
file_name_bor = strcat(file_name_source, file_name_number, '_bor.csv');
file_name_map = strcat(file_name_source, '.pgm');

% Ground Truth Beacon
if ...
	(file_name_source_number == 'Record_2018-02-08-12-33-53_filtered_1') | ...
	(file_name_source_number == 'Record_2018-02-08-12-33-53_filtered_2') | ...
	(file_name_source_number == 'Record_2018-02-08-12-33-53_filtered_3') | ...
	(file_name_source_number == 'Record_2018-02-08-12-33-53_filtered_7')
	
	data_bgt = [177 12.22 11.12; 178 12.22 11.44; 179 15.24 12.00; 180 14.20 10.12];
	
elseif ...
		(file_name_source_number == 'Record_2018-02-08-12-33-53_filtered_4') | ...
		(file_name_source_number == 'Record_2018-02-08-12-33-53_filtered_5') | ...
		(file_name_source_number == 'Record_2018-02-08-12-33-53_filtered_6')
	
	data_bgt = [1 1 0; 2 4 0; 3 4 2; 4 1 2] + [0 map.center(1) map.center(2)];
end

% Daten einlesen
data_pt = dlmread(file_name_pt, ';', 1, 0);
data_bor = dlmread(file_name_bor, ';', 1, 0);

% Zeiten und Positionen korrigieren
data_pt = data_pt(:, :) + [-data_pt(1, cid.time) 0 0 map.center(1) map.center(2) 0 0 0 0 0];
data_bor = data_bor(:, :) + [-data_bor(1, cid.time) 0 0 0 0 map.center(1) map.center(2) 0 0 0 0];

% Eindeutige Spalteninhalte bestimmen
unique_times = unique(data_bor(:, cid.time));
unique_bids = unique(data_bor(:, cid.bor_bid));

% Bild des OccupanyGrid laden, normalisieren und invertieren.
map_image = imread(file_name_map);
map_image = 1 - (map_image / 255);

% Karte anzeigen
occupancy_grid = robotics.OccupancyGrid(map_image, 1 / map.resolution);
show(occupancy_grid);
hold on; grid on; grid minor;
title('Virtuelle UWB Module');
xlabel('X [m]');
ylabel('Y [m]');

% Trajectorie einzeichnen
plot(data_pt(:, cid.x), data_pt(:, cid.y), '-');

% Ground Truth Beacon einzeichen
plot(data_bgt(:, 2), data_bgt(:, 3), 'k+', 'MarkerSize', 12, 'LineWidth', 1.5);

%
for t = linspace(0.05, 1, 5)
	%
	time = get_time(t, unique_times);

	% Pose einzeichnen
	selector = data_pt(:, cid.time) == time;
	data_pose = data_pt(selector, :);
	plot(data_pose(:, cid.x), data_pose(:, cid.y), 'bp', 'MarkerSize', 12);
	text(data_pose(:, cid.x)-0.05, data_pose(:, cid.y)+0.2, strcat('T=', num2str(round(time)), 's'));

	% Kovarianzen einzeichnen
	selector = data_bor(:, cid.time) == time;
	data_gauss = data_bor(selector, :);
	data_count = size(data_gauss, 1);
	
% 	for i = 1:data_count
% 		mean = data_gauss(i, [cid.bor_meanx cid.bor_meany]);
% 
% 		cov = [
% 			data_gauss(i, [cid.bor_cov00 cid.bor_cov01]);
% 			data_gauss(i, [cid.bor_cov10 cid.bor_cov11])];
% 		cov = cov * 1;
% 
% 		error_ellipse(cov, mean, 'conf', 0.997, 'style', 'r' );
% 
% 		plot([data_pose(:, cid.x); mean(1, 1)], [data_pose(:, cid.y); mean(1, 2)], 'b:');
% 	end

	fprintf('\\SI{%d}{\\second} & ', round(time));
	for b = 1:size(unique_bids, 1)
		
		selector = ...
			(data_bor(:, cid.time) <= time) & ...
			(data_bor(:, cid.bor_bid) == unique_bids(b));
		data_gauss = sortrows(data_bor(selector, :), cid.time);
		
		mean = data_gauss(end, [cid.bor_meanx cid.bor_meany]);

		cov = [
			data_gauss(end, [cid.bor_cov00 cid.bor_cov01]);
			data_gauss(end, [cid.bor_cov10 cid.bor_cov11])];
		cov = cov * 10;

		error_ellipse(cov, mean, 'conf', 0.997, 'style', 'r' );

		plot([data_pose(:, cid.x); mean(1, 1)], [data_pose(:, cid.y); mean(1, 2)], 'b:');
		
		selector = data_bgt(:, 1) == unique_bids(b);
		data_gt = data_bgt(selector, :);
		
		fprintf('\\SI{%.3f}{\\meter} & ', sqrt((data_gt(1, 2) - mean(1, 1)) .^ 2 + (data_gt(1, 3) - mean(1, 2)) .^ 2));
	end
	fprintf('\\\\\n');
end

% for i = 1:10:size(data_bor, 1)
% 	mean = data_bor(i, [cid.bor_meanx cid.bor_meany]);
% 	cov = [
% 		data_bor(i, [cid.bor_cov00 cid.bor_cov01]);
% 		data_bor(i, [cid.bor_cov10 cid.bor_cov11])
% 	];
% 	%cov = cov * 10;
% 
% 	error_ellipse(cov, mean, 'conf', 0.997, 'style', 'r' );
% end

% Legende
legend(...
	'Ground Truth Trajektorie', ...
	'Ground Truth UWB-Modul Position', ...
	'Ground Truth Position', ...
	'Fehlerellipse der UWB-Modul Position', ...
	'Location', 'Southwest');
%legend();
%'Zuordnung', ...

% Zoom into Figure
xlim([9 16]);
ylim([8 13]);
%axis equal;

% ax = gca;
% ax.XAxis.MinorTick = 'on';
% ax.XAxis.MinorTickValues = 9:0.1:16;
% ax.YAxis.MinorTick = 'on';
% ax.YAxis.MinorTickValues = 9:0.1:13;

file_name = strcat(file_name_source, file_name_number);
[file_path, file_name, file_ext] = fileparts(file_name);
file_saveas = fullfile(file_path, [file_name '_beacon_error']);
saveas(gcf, file_saveas, 'png');



function time=get_time(p, unique_times)
	count = size(unique_times, 1);
	range_in = [0 1];
	range_out = [1 count];
	idx = linear_mapping(p, range_in, range_out);
	idx = round(idx);
	idx = min(idx, range_out(2));
	idx = max(idx, range_out(1));
	time = unique_times(idx);
end


