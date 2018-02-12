%
% Bestimmen der Zeitspanne die notwendig ist um eine SOG/MC in eine
% Normalverteilung umzuwandeln.
%
close all; clear; clc;
format long; format compact;

%
%file_name_source = 'Record_2017-12-18-11-53-54';
file_name_source = 'Record_2018-02-08-12-33-53_filtered';
file_name_number = '_5';
file_name_source_number = strcat(file_name_source, file_name_number);
file_name_bor = strcat(file_name_source, file_name_number, '_bor.csv');

% Daten einlesen
data_bor = dlmread(file_name_bor, ';', 1, 0);

% Positionen korrigieren
data_bor = data_bor + [-data_bor(1, cid.time) 0 0 0 0 0 0 0 0 0 0];

% Verfügbare Beacon IDs bestimmen
unique_bid = unique(data_bor(:, cid.bor_bid));
unique_bid_count = size(unique_bid, 1);

%
times=[];

%
for b = 1:unique_bid_count
	
	%
	bid = unique_bid(b);
	
	%
	selector = (data_bor(:, cid.bor_bid) == bid) & (data_bor(:, cid.bor_pdf) ~= 1);
	data = sort(data_bor(selector, :), cid.time);
	
	%
	times = [times; ...
		bid data(end, cid.time) - data(1, cid.time)];
	
end

%
times