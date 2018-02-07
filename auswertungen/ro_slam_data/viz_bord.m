%
% Vizualisieren der Beacon Fehlerellipsen über die Lebenszeit.
%

close all; clear; clc;
format long; format compact;

% Konstanten
bid = 4;

subplot_m = 3;
subplot_n = 4;
subplot_count = (subplot_m * subplot_n);

map_resolution = 0.02;
map_size = [1024 1024];
map_center = (map_size * map_resolution) / 2;

bgt=[521 554; 523 460; 715 557; 716 463];
bgt=[0 map_size(2)]-bgt;
bgt=bgt.*[-1 1];
bgt=bgt*map_resolution;

% Dateipfad
source_file_name = 'Record_2017-12-18-11-53-54';
pt_file_name = strcat(source_file_name, '_pt.csv');
bor_file_name = strcat(source_file_name, '_bor.csv');
bord_file_name = strcat(source_file_name, '_bord.csv');

% Daten einlesen
pt_data = dlmread(pt_file_name, ';', 1, 0);
bor_data = dlmread(bor_file_name, ';', 1, 0);
bord_data = dlmread(bord_file_name, ';', 1, 0);

%
unique_beacons = unique(bord_data(:, cid.bord_bid));

bid = min(max(bid, 1), size(unique_beacons, 1));
bid = unique_beacons(bid);

selector = bord_data(:, cid.bord_bid) == bid;
unique_times = unique(bord_data(selector, cid.time));


% Bild des OccupanyGrid laden, normalisieren und invertieren.
map_image = imread('map.pgm');
map_image = 1 - (map_image / 255);

% Karte laden
map = robotics.OccupancyGrid(map_image, 1 / map_resolution);

% Iterieren über alle subplots
for p = 1:subplot_count

	% Subplot auswählen
	subplot(subplot_m, subplot_n, p);
	
	%
	time_p = linear_mapping(p, [1 subplot_count], [0 1]);
	time = get_time(time_p, unique_times);
	
	% Karte anzeigen
	show(map);
	hold on; grid on; grid minor;
	title(strcat('Time=', num2str(time_p*100), '%'));
	
	% Ground Truth Beacon einzeichen.
	plot(bgt(:, 1), bgt(:, 2), 'r+', 'MarkerSize', 10);
	
	%
	selector = and( ...
		logical(bord_data(:, cid.time) == time), ...
		logical(bord_data(:, cid.bord_bid) == bid));
	data_bord_bid_time = bord_data(selector, :);
	
	% Iterieren über alle elipsen/partikel
	for i = 1:size(data_bord_bid_time, 1)
		
		mean = data_bord_bid_time(i, [cid.bord_x cid.bord_y]);
		mean = mean + map_center;
		
		cov = [
			data_bord_bid_time(i, [cid.bord_cov00 cid.bord_cov01]);
			data_bord_bid_time(i, [cid.bord_cov10 cid.bord_cov11])];
		%cov = cov * 100;
		
		error_ellipse(cov, mean, 'conf', 0.997, 'style', 'r' );
		
	end
	
	% Legende
	legend('Beacon Ground Truth', 'Error Ellipse(s)');
	
	% Zoom into Figure
	xlim([8 17]);
	ylim([8 14]);
	%axis equal;
	
end



% % Eindeutige Spalteninhalte bestimmen
% unique_bids = unique(bord_data(:, cid.bord_bid));
% 
% % Iterieren über alle Beacons
% %for b = 1:size(unique_bids, 1)
% for b = 1
% 	
% 	% Beacon ID bestimmen
% 	bid = unique_bids(b);
% 	
% 	% Nur die Daten mit dieser Beacon ID selektieren
% 	selector = bord_data(:, cid.bord_bid) == bid;
% 	data = bord_data(selector, :);
% 	
% 	% Eindeutlige Zeiten für den Beacon bestimmen
% 	unique_times = unique(data(:, cid.time));
% 	
% 	% Iterieren über ausgewählte Zeiten
% 	for t = linspace(0, 1, 2)
% 		
% 		time = get_time(t, unique_times);
% 		
% 		selector = data(:, cid.time) == time;
% 		data_bord_bid_time = data(selector, :);
% 		
% 		% Iterieren über alle elipsen/partikel
% 		for i = 1:size(data_bord_bid_time, 1)
% 						
% 			mean = data_bord_bid_time(i, [cid.bord_x cid.bord_y]);
% 			mean = mean + map_center;
% 
% 			cov = [
% 				data_bord_bid_time(i, [cid.bord_cov00 cid.bord_cov01]);
% 				data_bord_bid_time(i, [cid.bord_cov10 cid.bord_cov11])];
% 			%cov = cov * 10;
% 
% 			error_ellipse(cov, mean, 'conf', 0.997, 'style', 'r' );
% 	
% 		end
% 		
% 	end
% 	
% end
% 
% % Zoom into Figure
% xlim([9 16]);
% ylim([9 13]);
% axis equal;
% 
% ax = gca;
% ax.XAxis.MinorTick = 'on';
% ax.XAxis.MinorTickValues = 9:0.1:16;
% ax.YAxis.MinorTick = 'on';
% ax.YAxis.MinorTickValues = 9:0.1:13;


function time = get_time(p, unique_times)
	count = size(unique_times, 1);
	range_in = [0 1];
	range_out = [1 count];
	idx = linear_mapping(p, range_in, range_out);
	idx = round(idx);
	idx = min(idx, range_out(2));
	idx = max(idx, range_out(1));
	time = unique_times(idx);
end