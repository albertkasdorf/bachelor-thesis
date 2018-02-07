%
% Vizualisieren einer kompletten Beacon Kette.
% Von SOG/Partikel-Verteilung zu einer Gauss-Vertielung.
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
data_pt = dlmread(pt_file_name, ';', 1, 0);
data_bor = dlmread(bor_file_name, ';', 1, 0);
data_bord = dlmread(bord_file_name, ';', 1, 0);

% Bild des OccupanyGrid laden, normalisieren und invertieren.
map_image = imread('map.pgm');
map_image = 1 - (map_image / 255);

% Karte laden
map = robotics.OccupancyGrid(map_image, 1 / map_resolution);

%
unique_times = unique(data_pt(:, cid.time));
unique_beacons = unique(data_bor(:, cid.bor_bid));

%
bid = min(max(bid, 1), size(unique_beacons, 1));
bid = unique_beacons(bid);

% Iterieren über alle subplots
for p = 1:subplot_count

	% Subplot auswählen
	subplot(subplot_m, subplot_n, p);
	
	%
	time_p = linear_mapping(p, [1 subplot_count], [0 1]);
	time = get_time(time_p, unique_times);
	
	selector = and( ...
		logical(data_bor(:, cid.time) == time), ...
		logical(data_bor(:, cid.bor_bid) == bid));
	data_bor_bid_time = data_bor(selector, :);
	
	selector = and( ...
		logical(data_bord(:, cid.time) == time), ...
		logical(data_bord(:, cid.bord_bid) == bid));
	data_bord_bid_time = data_bord(selector, :);
	
	if size(data_bor_bid_time, 1) ~= 1
		continue
	end
	
	% Karte anzeigen
	show(map);
	hold on; grid on; grid minor;
	title(strcat('Time=', num2str(time_p*100), '%'));
	
	% Ground Truth Beacon einzeichen.
	plot(bgt(:, 1), bgt(:, 2), 'r+', 'MarkerSize', 10);
	
	% Trajektorie bis zu diesem Punkt
	selector = data_pt(:, cid.time) <= time;
	data_pt_time = data_pt(selector, [cid.x cid.y]);
	plot(data_pt_time(:, 1) + map_center(1), data_pt_time(:, 2) + map_center(2), 'g-');
		
	% MC
	if data_bor_bid_time(1, cid.bor_pdf) == 0
	end
	
	% Gaussian
	if data_bor_bid_time(1, cid.bor_pdf) == 1
		
		mean = data_bor_bid_time(1, [cid.bor_meanx cid.bor_meany]);
		mean = mean + map_center;
		
		cov = [
			data_bor_bid_time(1, [cid.bord_cov00 cid.bord_cov01]);
			data_bor_bid_time(1, [cid.bord_cov10 cid.bord_cov11])];
		cov = cov * 100;
		
		error_ellipse(cov, mean, 'conf', 0.997, 'style', 'r' );
		
	end
	
	% SOG
	if data_bor_bid_time(:, cid.bor_pdf) == 2
		
		% Iterieren über alle elipsen/partikel
		for i = 1:size(data_bord_bid_time, 1)
			
			mean = data_bord_bid_time(i, [cid.bord_x cid.bord_y]);
			mean = mean + map_center;
			
			cov = [
				data_bord_bid_time(i, [cid.bord_cov00 cid.bord_cov01]);
				data_bord_bid_time(i, [cid.bord_cov10 cid.bord_cov11])];
			cov = cov * 10;
			
			error_ellipse(cov, mean, 'conf', 0.997, 'style', 'r' );
			
		end
		
	end
	
	% Legende
	legend('Beacon Ground Truth', 'Trajectory', 'Error Ellipse(s)');
	
	% Zoom into Figure
	xlim([8 17]);
	ylim([8 14]);
	%axis equal;
	
end






















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