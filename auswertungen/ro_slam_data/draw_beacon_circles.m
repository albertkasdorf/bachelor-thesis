%
% Zeichnen einiger/aller Entfernungskreise an den entsprechenden Positionen
% auf der Trajektorie.
%
close all; clear; clc;
format long; format compact;

% Konstanten
bid = 177;
map_resolution = 0.02;
map_size = [1024 1024];
map_center = (map_size * map_resolution) / 2;

% Dateinamen
file_name_source = 'Record_2017-12-18-11-53-54';
file_name_pt = strcat(file_name_source, '_pt.csv');
file_name_br = strcat(file_name_source, '_beacon_raw.csv');
file_name_map = strcat(file_name_source, '.pgm');

% Daten einlesen
data_pt = dlmread(file_name_pt, ';', 1, 0);
data_br = dlmread(file_name_br, ';', 1, 0);

% Zeit und Positionen korrigieren
data_pt = data_pt(:, :) + [0 0 0 map_center(1) map_center(2) 0 0 0 0 0];

% Bild des OccupanyGrid laden, normalisieren und invertieren.
map_image = imread(file_name_map);
map_image = 1 - (map_image / 255);

%
unique_sec = unique(data_pt(:, cid.p_sec));
uniuqe_sec_count = size(unique_sec, 1);

%
figure('Position', [50 50 1024 600], 'DefaultAxesFontSize', 12);
hold on; grid on; grid minor;

% Karte anzeigen
occupancy_grid = robotics.OccupancyGrid(map_image, 1 / map_resolution);
show(occupancy_grid);

% Trajektorie einzeichen
plot(data_pt(:, cid.x), data_pt(:, cid.y), 'r');

%
%for t = 1:size(unique_sec, 1)
for t = round(linspace(1, uniuqe_sec_count, min(50, uniuqe_sec_count)))
%for t = 1:10
	
	%
	sec = unique_sec(t);
	
	%
	selector = data_pt(:, cid.p_sec) == sec;
	data = data_pt(selector, :);
	x = mean(data(:, cid.x));
	y = mean(data(:, cid.y));
	
	%
	selector = and(...
		data_br(:, cid.p_sec) == sec, ...
		data_br(:, cid.b_id) == bid);
	data = data_br(selector, :);
	
	if size(data, 1) == 0
		continue;
	end
	r = mean(data(:, cid.b_range));
	
	%
	viscircles([x, y], r, 'LineStyle', '-', 'Color', [0 0 0 0.25], 'LineWidth', 0.01);
	plot(x, y, 'bo');
end

% Zoom into Figure
xlim([8 17]);
ylim([5 16]);
%axis equal;
title('');
