%
% Visualisieren der Beacon Positionsunterschiede zwischen dem Ground Truth
% und den geschätzten Mittelwert.
%
close all; clear; clc;
format long; format compact;

% Kartenparameter
map_resolution = 0.02;
map_size = [1024 1024];
map_center = (map_size * map_resolution) / 2;

%
%file_name_source = 'Record_2017-12-18-11-53-54';
file_name_source = 'Record_2018-02-08-12-33-53_filtered';
file_name_number = '_1';
file_name_source_number = strcat(file_name_source, file_name_number);
file_name_pt = strcat(file_name_source, file_name_number, '_pt.csv');
file_name_bor = strcat(file_name_source, file_name_number, '_bor.csv');
file_name_map = strcat(file_name_source, '.pgm');

% Ground Truth Beacon
if ...
	(file_name_source_number == 'Record_2018-02-08-12-33-53_filtered_1') | ...
	(file_name_source_number == 'Record_2018-02-08-12-33-53_filtered_2') | ...
	(file_name_source_number == 'Record_2018-02-08-12-33-53_filtered_3')
	
	data_bgt = [177 12.22 11.12; 178 12.22 11.44; 179 15.24 12.00; 180 14.20 10.12];
	
elseif ...
		(file_name_source_number == 'Record_2018-02-08-12-33-53_filtered_4') | ...
		(file_name_source_number == 'Record_2018-02-08-12-33-53_filtered_5')
	
	data_bgt = [1 1 0; 2 4 0; 3 4 2; 4 1 2] + [0 map_center(1) map_center(2)];
end


% Daten einlesen
data_pt = dlmread(file_name_pt, ';', 1, 0);
data_bor = dlmread(file_name_bor, ';', 1, 0);

% Positionen korrigieren
data_pt = data_pt + [0 0 0 map_center(1) map_center(2) 0 0 0 0 0];
data_bor = data_bor + [0 0 0 0 0 map_center(1) map_center(2) 0 0 0 0];

% Bild des OccupanyGrid laden, normalisieren und invertieren.
data_map = imread(file_name_map);
data_map = 1 - (data_map / 255);
occupancy_grid = robotics.OccupancyGrid(data_map, 1 / map_resolution);

%
figure('Position', [50 50 1024 600], 'DefaultAxesFontSize', 16);

%
show(occupancy_grid);
hold on; grid on; grid minor;

% 
%plot(data_pt(:, cid.x), data_pt(:, cid.y));

%
unique_bid = unique(data_bor(:, cid.bor_bid));
for b = 1:size(unique_bid, 1)
	bid = unique_bid(b);
	
	selector = data_bor(:, cid.bor_bid) == bid;
	data = data_bor(selector, :);
	plot(data(:, cid.bor_meanx), data(:, cid.bor_meany), '+');
	
	selector = data_bgt(:, 1) == bid;
	data = data_bgt(selector, :);
	plot(data(:, 2), data(:, 3), 'o');
	
end

%
xlim([9 16]);
ylim([8 13]);

