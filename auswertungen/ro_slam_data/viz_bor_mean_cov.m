close all; clear; %clc;
format long; format compact;

% Globale Variablen

% Konstanten
map_resolution = 0.02;
map_size = [1024 1024];
map_center = (map_size * map_resolution) / 2;
	
% Dateipfad
source_file_name = 'Record_2017-12-18-11-53-54';
pt_file_name = strcat(source_file_name, '_pt.csv');
bor_file_name = strcat(source_file_name, '_bor.csv');

% Daten einlesen
pt_data = dlmread(pt_file_name, ';', 1, 0);
bor_data = dlmread(bor_file_name, ';', 1, 0);

% Eindeutige Spalteninhalte bestimmen
unique_times = unique(bor_data(:, cid.time));
unique_bids = unique(bor_data(:, cid.bor_bid));

% Bild des OccupanyGrid laden, normalisieren und invertieren.
map_image = imread('map.pgm');
map_image = 1 - (map_image / 255);

% Karte anzeigen
map = robotics.OccupancyGrid(map_image, 1 / map_resolution);
show(map);
hold on; grid on; grid minor;

for t = linspace(0, 1, 5)
	%
	time = get_time(t, unique_times);

	%
	selector = bor_data(:, cid.time) == time;
	bor_data_selection = bor_data(selector, :);
	selector = pt_data(:, cid.time) == time;
	pt_data_selection = pt_data(selector, :);

	% Pose einzeichnen
	pose = pt_data_selection(:, [cid.x cid.y]);
	pose = pose + map_center;
	plot(pose(1), pose(2), 'gp', 'MarkerSize', 16 );
	text(pose(1), pose(2)-0.1, strcat('T=', num2str(t), '%'));

	% Kovarianzen einzeichnen
	for i = 1:size(bor_data_selection, 1)
		mean = bor_data_selection(i, [cid.bor_meanx cid.bor_meany]);
		mean = mean + map_center;

		cov = [
			bor_data_selection(i, [cid.bor_cov00 cid.bor_cov01]);
			bor_data_selection(i, [cid.bor_cov10 cid.bor_cov11])];
		cov = cov * 10;

		error_ellipse(cov, mean, 'conf', 0.997, 'style', 'r' );

		plot([pose(1); mean(1, 1)], [pose(2); mean(1, 2)], 'b:');
	end

end

% Trajectorie einzeichnen
plot(pt_data(:, cid.x) + map_center(1), pt_data(:, cid.y) + map_center(2), 'm-');

% Legende
legend('Position Odometrie','Position Error Ellipse (Factor 10)','Range');

% Zoom into Figure
xlim([9 16]);
ylim([9 13]);
axis equal;

ax = gca;
ax.XAxis.MinorTick = 'on';
ax.XAxis.MinorTickValues = 9:0.1:16;
ax.YAxis.MinorTick = 'on';
ax.YAxis.MinorTickValues = 9:0.1:13;



function time=get_time(p, unique_times)
	count = size(unique_times, 1);
	range_in = [0 1];
	range_out = [1 count];
	idx = linear_mapping(p, range_in, range_out);
	idx = round(idx);
	idx = min(idx, range_out(2));
	idx = max(idx, range_out(1));
	time = unique_times(idx);
end


