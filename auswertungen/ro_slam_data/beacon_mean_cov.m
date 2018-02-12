%
% Aufzeigen der Fehlerellipsen über die Zeit pro Beacon.
%
close all; clear; clc;
format long; format compact;

% Konstanten
time_range = [0 0.5];

subplot_m = 2;
subplot_n = 2;
subplot_count = (subplot_m * subplot_n);

%
%file_name_source = 'Record_2017-12-18-11-53-54';
file_name_source = 'Record_2018-02-08-12-33-53_filtered';
file_name_number = '_1';
file_name_source_number = strcat(file_name_source, file_name_number);
file_name_bor = strcat(file_name_source, file_name_number, '_bor.csv');
file_name_map = strcat(file_name_source, '.pgm');

% Daten einlesen
data_bor = dlmread(file_name_bor, ';', 1, 0);

% Positionen korrigieren
data_bor = data_bor + [-data_bor(1, cid.time) 0 0 0 0 map.center(1) map.center(2) 0 0 0 0];

% Bild des OccupanyGrid laden, normalisieren und invertieren.
data_map = imread(file_name_map);
data_map = 1 - (data_map / 255);
occupancy_grid = robotics.OccupancyGrid(data_map, 1 / map.resolution);

%
uniq_bid = unique(data_bor(:, cid.bor_bid));
uniq_bid_count = size(uniq_bid, 1);

%
figure('Position', [50 50 1024 600], 'DefaultAxesFontSize', 16);

% Iterieren über alle subplots
for p = 1:subplot_count

	% Subplot auswählen
	subplot(subplot_m, subplot_n, p);
	show(occupancy_grid);
	hold on; grid on; grid minor;
	
	%
	bid_index = p;
	bid = uniq_bid(max(1, min(uniq_bid_count, bid_index)));
	
	% Daten kürzen um bid
	selector = data_bor(:, cid.bor_bid) == bid;
	data = data_bor(selector, :);
	data_count = size(data, 1);
	
	%
	i_start = max(1, round(data_count * time_range(1)));
	i_end = min(data_count, round(data_count * time_range(2)));
	
	%
	for i = i_start:i_end
		
		mean = data(i, [cid.bor_meanx cid.bor_meany]);

		cov = [
			data(i, [cid.bor_cov00 cid.bor_cov01]);
			data(i, [cid.bor_cov10 cid.bor_cov11])];

		error_ellipse(cov, mean, 'conf', 0.997, 'style', 'r' );
		plot(mean(1), mean(2), 'b+');
	
	end

	plot(data(:, cid.bor_meanx), data(:, cid.bor_meany), '-');
	
	title(['beacon\_id: ' num2str(bid)]);
end

%
%xlim([4 18]);
%ylim([4 16]);





