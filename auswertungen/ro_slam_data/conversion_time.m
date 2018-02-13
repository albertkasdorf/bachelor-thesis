%
% Bestimmen der Zeitspanne die notwendig ist um eine SOG/MC in eine
% Normalverteilung umzuwandeln.
%
close all; clear; clc;
format long; format compact;

%
%file_name_source = 'Record_2017-12-18-11-53-54';
file_name_source = 'Record_2018-02-08-12-33-53_filtered';
file_name_number = '_6';
file_name_source_number = strcat(file_name_source, file_name_number);
file_name_bor = strcat(file_name_source, file_name_number, '_bor.csv');
file_name_pt = strcat(file_name_source, file_name_number, '_pt.csv');

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
data_pt = dlmread(file_name_pt, ';', 1, 0);

% Positionen korrigieren
data_bor = data_bor + [-data_bor(1, cid.time) 0 0 0 0 map.center(1) map.center(2) 0 0 0 0];
data_pt = data_pt + [-data_pt(1, cid.time) 0 0 map.center(1) map.center(2) 0 0 0 0 0];

% Verfügbare Beacon IDs bestimmen
unique_bid = unique(data_bor(:, cid.bor_bid));
unique_bid_count = size(unique_bid, 1);

%
data_stat=[];

%
for b = 1:unique_bid_count
	
	%
	bid = unique_bid(b);
	
	%
	selector = data_bgt(:, 1) == bid;
	gt = data_bgt(selector, :);
	
	%
	selector = (data_bor(:, cid.bor_bid) == bid) & (data_bor(:, cid.bor_pdf) == 1);
	data = sort(data_bor(selector, :), cid.time);
	
	%
	time = data(1, cid.time);
	range_beacon = sqrt((data(1, cid.bor_meanx) - gt(1, 2)) .^ 2 + (data(1, cid.bor_meany) - gt(1, 3)) .^ 2);
	
	%
	selector = (data_pt(:, cid.time) == time);
	data = data_pt(selector, :);
	range_robot = sqrt((data(1, cid.x) - data_pt(1, cid.x)) .^ 2 + (data(1, cid.y) - data_pt(1, cid.y)) .^ 2);

	%
	data_stat = [data_stat; ...
		bid time range_robot];
	
end

%
data_stat

fprintf('\\hline\n');
fprintf('\\gls{uwbm} & ID & Verfahren & Zeitspanne & Entfernung \\\\\n');
fprintf(' & & [\\si{\\second}] & [\\si{\\meter}] & \\\\\n');
fprintf('\\hline\n');
fprintf('\\hline\n');
fprintf('Virtuell & \\num{%.d} & \\gls{mc} & \\num{%.1f} & \\num{%.3f}\\\\\n', data_stat');
fprintf('\\hline\n');













