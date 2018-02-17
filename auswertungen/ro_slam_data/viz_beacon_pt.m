%
% ???
%
close all; clear; clc;
format long; format compact;

subplot_m = 2;
subplot_n = 2;
subplot_count = (subplot_m * subplot_n);

%
file_name_source = 'Record_2018-02-08-12-33-53_filtered';
file_name_number = '_1';
file_name_source_number = strcat(file_name_source, file_name_number);
file_name_pt = strcat(file_name_source, file_name_number, '_pt.csv');
file_name_beacon = strcat(file_name_source, file_name_number, '_beacon.csv');
file_name_map = strcat(file_name_source, '.pgm');

% Daten einlesen
data_pt = dlmread(file_name_pt, ';', 1, 0);
data_beacon = dlmread(file_name_beacon, ';', 1, 0);

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



