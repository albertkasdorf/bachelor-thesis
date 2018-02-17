%
% ???
%
close all; clear; clc;
format long; format compact;

%
file_name_index = 1;
file_name_sources = [
	'2018-02-08-12-30-43';	% (1) Erste Beacon Position
	'2018-02-08-12-33-53';
	'2018-02-08-12-37-13';
	'2018-02-08-13-09-17';	% (4) Zweite Beacon Position:
	'2018-02-08-13-14-00';
	'2018-02-08-13-11-41';
	'2018-02-08-14-05-19';	% (7) NLOS Aufnahmen
	'2018-02-08-14-08-02';
	'2018-02-08-14-10-05';
	'2018-02-08-14-11-11';
	'2018-02-08-14-25-21';	% (11) Symmetrische Anordnung
	'2018-02-08-14-27-57';
	'2018-02-08-14-53-24';	% (13) Default Antenna delay
	'2018-02-08-14-56-49';
	'2018-02-08-14-59-13'];
file_name_source = file_name_sources(file_name_index, :);
file_name_pt = strcat('./data/', file_name_source, '_pt.csv');
file_name_beacon = strcat('./data/', file_name_source, '_beacon.csv');
file_name_map = strcat('./data/', file_name_source, '.pgm');

% Daten einlesen
data_pt = dlmread(file_name_pt, ';', 1, 0);
data_beacon = dlmread(file_name_beacon, ';', 1, 0);

if file_name_index >= 1 && file_name_index <= 3
	data_gt = [177 12.22 11.12; 178 12.22 11.44; 179 15.24 12.00; 180 14.20 10.12];
elseif file_name_index >= 4 && file_name_index <= 10
	data_gt = [177 12.22 11.12; 178 10.24 12.00; 179 15.24 12.00; 180 14.20 10.12];
elseif file_name_index >= 11 && file_name_index <= 12
	data_gt = [177 10.24 12.00; 178 14.20 12.00; 179 14.20 10.12; 180 10.24 10.12];
else
	data_gt = [177 0.0 0.0; 178 0.0 0.0; 179 0.0 0.0; 180 0.0 0.0];
end

% Bild des OccupanyGrid laden, normalisieren und invertieren.
data_map = imread(file_name_map);
data_map = 1 - (data_map / 255);
occupancy_grid = robotics.OccupancyGrid(data_map, 1 / map.resolution);

%
%viz_beacon_pt_range_time(data_pt, data_beacon)
viz_beacon_pt_error(data_pt, data_beacon, data_gt, occupancy_grid);




function viz_beacon_pt_error(pt, beacon, gt, occupancy_grid)
	
	%
	subplot_m = 3;
	subplot_n = 2;
	subplot_count = (subplot_m * subplot_n);

	% Daten korrigieren
	pt = pt + [-pt(1, cid.time) 0 0 map.center(1) map.center(2) 0 0 0 0 0];
	beacon = beacon + [-beacon(1, cid.time) 0 0 0 0 0 0 0 0 0 0 0];
	gt = gt + [0 0 0];

	% Trajektorie interpolieren
	interp_trajektorie = interp1(pt(:, cid.time), pt(:, [cid.x cid.y]), beacon(:, cid.time));
	
	%
	uniq_bids = sortrows(unique(beacon(:, cid.beacon_anchor_address)));
	
	%
	for b = 1:size(uniq_bids, 1)
		%
		bid = uniq_bids(b);
		
		%
		selector = beacon(:, cid.beacon_anchor_address) == bid;
		data_beacon_bid = beacon(selector, :);
		interp_trajektorie_bid = interp_trajektorie(selector, :);
		data_gt_bid = ones(size(data_beacon_bid, 1), 2) .* gt(b, [2 3]);
		
		range_gt = sqrt((interp_trajektorie_bid(:, 1) - data_gt_bid(:, 1)) .^ 2 + (interp_trajektorie_bid(:, 2) - data_gt_bid(:, 2)) .^ 2);
		range = [data_beacon_bid(:, [cid.time cid.beacon_range]) range_gt];
		
		subplot(subplot_m, subplot_n, b);
		plot(range(:, 1), range(:, 3) - range(:, 2));
		grid on; grid minor;
		xlabel('time [s]'); ylabel('distance error [m]');
		title(['Beacon: ' num2str(bid)]);
		ylim([-1.5 1.5]);
		
	end
	
	subplot(subplot_m, subplot_n, 5);
	show(occupancy_grid);
	hold on; grid on; grid minor;
	plot(pt(:, cid.x), pt(:, cid.y));
	plot(gt(:, 2), gt(:, 3), '+');
	%axis equal;
	xlim([10 16]);
	ylim([9 13]);
	title('');
	xlabel(''); ylabel('');
	
end


function viz_beacon_pt_range_time(data_pt, data_beacon)
	%
	subplot_m = 2;
	subplot_n = 2;
	subplot_count = (subplot_m * subplot_n);

	% Positionen korrigieren
	data_pt = data_pt + [0 -data_pt(1, cid.p_sec) 0 map.center(1) map.center(2) 0 0 0 0 0];
	data_beacon = data_beacon + [0 -data_beacon(1, cid.p_sec) 0 0 0 0 0 0 0 0 0 0];
	
	%
	pt_pos0 = ones(size(data_pt, 1), 2) .* data_pt(1, [cid.x cid.y]);
	pt_pos = data_pt(:, [cid.x cid.y]);
	pt_range = sqrt((pt_pos0(:, 1) - pt_pos(:, 1)) .^ 2 + (pt_pos0(:, 2) - pt_pos(:, 2)) .^ 2);
	
	%
	uniq_bid = unique(data_beacon(:, cid.beacon_anchor_address));
	
	%
	%figure('Position', [50 50 1024 600], 'DefaultAxesFontSize', 16);
	figure('Position', [50 50 1024 600]);
	
	% Iterieren über alle subplots
	for sp = 1:subplot_count
		
		% Subplot auswählen
		subplot(subplot_m, subplot_n, sp);
		hold on; grid on; grid minor;
		
		%
		bid_index = sp;
		bid = uniq_bid(max(1, min(size(uniq_bid, 1), bid_index)));
		
		% Daten kürzen um bid
		selector = data_beacon(:, cid.beacon_anchor_address) == bid;
		data_filtered = data_beacon(selector, :);
		
		%
		plot(data_filtered(:, cid.p_sec), data_filtered(:, cid.beacon_range), '.');
		plot(data_pt(:, cid.p_sec), pt_range, '.');
		
		%
		ylim([0 7]);
		xlabel('time [t]');
		ylabel('range [m]');
		title(['Beacon: ' num2str(bid)]);
		
	end
end
