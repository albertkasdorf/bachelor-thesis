%
% Visualisieren der Entfernung der Beacons zum Ground Truth als
% Plot
%
close all; clear; clc;
format long; format compact;

% Konstanten
subplot_m = 2;
subplot_n = 2;
subplot_count = (subplot_m * subplot_n);

data_stat = [];

%
file_name_source = 'Record_2018-02-08-12-33-53_filtered';
file_name_number = '_5';
file_name_source_number = strcat(file_name_source, file_name_number);
file_name_bor = strcat(file_name_source, file_name_number, '_bor.csv');

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
data_bor = dlmread(file_name_bor, ';', 1, 0);

% Positionen korrigieren
data_bor = data_bor + [-data_bor(1, cid.time) 0 0 0 0 map.center(1) map.center(2) 0 0 0 0];

%
figure('Position', [50 50 1024 600], 'DefaultAxesFontSize', 16);
%figure('Position', [50 50 1024 600]);

%
unique_bid = unique(data_bor(:, cid.bor_bid));
for bindex = 1:size(unique_bid, 1)
	
	%
	bid = unique_bid(bindex);
	
	% Ground Truth zu einer bid bestimmen
	selector = data_bgt(:, 1) == bid;
	gt = data_bgt(selector, [2 3]);
	
	% Positionen zu einem bid bestimmen
	selector = data_bor(:, cid.bor_bid) == bid;
	time = data_bor(selector, cid.time);
	mean = data_bor(selector, [cid.bor_meanx cid.bor_meany]);
		
	%
	range = sqrt((mean(:, 1) - gt(:, 1)) .^ 2 + (mean(:, 2) - gt(:, 2)) .^ 2);
		
	%
	selector = (data_bor(:, cid.bor_bid) == bid) & (data_bor(:, cid.bor_pdf) == 1);
	gauss_switch_time = sortrows(data_bor(selector, :), cid.time);
	gauss_switch_time = gauss_switch_time(1, cid.time);
	
	%
	%subplot(subplot_m, subplot_n, bindex);
	plot(time, range, 'DisplayName', ['Beacon ID: ' num2str(bid)]);
	%title(['Beacon ID: ' num2str(bid)]);
	xlabel('Zeit [s]');
	ylabel('Entfernung zum Ground Truth [m]');
	hold on; grid on; grid minor;
	
	%xlim([time(1) time(end)]);
	%ylim([0 7]);
	%ylim([0 3]);
	
	%plot(time, cov_det, 'b');
	
	%
	%vline(gauss_switch_time, 'r-', 'Konvertierung zu einem EKF');
	vline(gauss_switch_time, 'r:');
end
legend();

