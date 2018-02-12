%
% Vizualisieren Partikel Filter Ringe
%
close all; clear; clc;
format long; format compact;

% Konstanten
subplot_m = 2;
subplot_n = 3;
subplot_count = (subplot_m * subplot_n);

%
file_name_source = 'Record_2018-02-08-12-33-53_filtered';
file_name_number = '_7';
file_name_source_number = strcat(file_name_source, file_name_number);
file_name_bord = strcat(file_name_source, file_name_number, '_bord.csv');
file_name_pt = strcat(file_name_source, file_name_number, '_pt.csv');
file_name_map = strcat(file_name_source, '.pgm');

% Daten einlesen
data_bord = dlmread(file_name_bord, ';', 1, 0);
data_pt = dlmread(file_name_pt, ';', 1, 0);

% Positionen korrigieren
data_bord = data_bord + [-data_bord(1, cid.time) 0 0 0 map.center(1) map.center(2) 0 0 0 0 0];
data_pt = data_pt + [-data_pt(1, cid.time) 0 0 map.center(1) map.center(2) 0 0 0 0 0];

% Bild des OccupanyGrid laden, normalisieren und invertieren.
data_map = imread(file_name_map);
data_map = 1 - (data_map / 255);
occupancy_grid = robotics.OccupancyGrid(data_map, 1 / map.resolution);

%
figure('Position', [50 50 1024 600]);

%
uniq_times = unique(data_bord(:, cid.time));
uniq_times_count = size(uniq_times, 1);

%
for t = 1:uniq_times_count

	%
	time = uniq_times(t);
	
	%
	if t > subplot_count
		break;
	end
	subplot(subplot_m, subplot_n, t);
	
	%
	show(occupancy_grid);
	hold on; grid on; grid minor;
	title(['Zeitpunkt: ' num2str(time) 's']);
	xlabel('X [m]');
	ylabel('Y [m]');
	
	% Trajektorie bis zu diesem Zeitpunkt
	selector = data_pt(:, cid.time) <= time;
	data = data_pt(selector, :);
	plot(data(1, cid.x), data(1, cid.y), 'o', 'DisplayName', 'Startpunkt');
	plot(data(:, cid.x), data(:, cid.y), '-', 'DisplayName', 'Trajektorie');
	
	%
	selector = data_bord(:, cid.time) == time;
	data = data_bord(selector, :);
		
	%
	uniq_bid = unique(data(:, cid.bord_bid));
	for b = 1:size(uniq_bid, 1)
		
		%
		bid = uniq_bid(b);
		
		%
		selector = (data_bord(:, cid.time) == time) & (data_bord(:, cid.bord_bid) == bid);
		data = data_bord(selector, :);
		
		%
		plot(data(:,cid.bord_x), data(:, cid.bord_y), '.', 'DisplayName', ['Beacon ID: ' num2str(bid)]);
	end
	
	%
	xlim([5 15]);
	ylim([5 15]);
	%legend();
	
end







