%
% Vizualisieren der Unterschied zwischen der Robotino-/rf2o- und lsm-Odometrie.
%
close all; clear; clc;
format long; format compact;

% Konstanten
save_to_disk = false;

cid_time = 1;
cid_x = 4;
cid_y = 5;

subplot_m = 2;
subplot_n = 2;
subplot_count = (subplot_m * subplot_n);

% Kartenparameter
map_resolution = 0.02;
map_size = [1024 1024];
map_center = (map_size * map_resolution) / 2;

% Dateipfad
%file_name = 'Record_2018-02-08-12-30-43';
file_name = 'Record_2018-02-08-12-33-53';
%file_name = 'Record_2018-02-08-13-09-17';

robo_file_name = strcat(file_name, '_odom_robotino.csv');
lsm_file_name = strcat(file_name, '_odom_lsm.csv');
rf2o_file_name = strcat(file_name, '_odom_rf2o.csv');
map_file_name = strcat(file_name, '_map_robotino.csv');
image_file_name = strcat(file_name, '.pgm');

%
robo = dlmread(robo_file_name, ';', 1, 0);
lsm = dlmread(lsm_file_name, ';', 1, 0);
rf2o = dlmread(rf2o_file_name, ';', 1, 0);
map = dlmread(map_file_name, ';', 1, 0);

% Zeit und Positionen korrigieren
robo = robo(:, :) + [-robo(1, cid_time) 0 0 map_center(1) map_center(2) 0 0 0 0 0];
lsm = lsm(:, :) + [-lsm(1, cid_time) 0 0 map_center(1) map_center(2) 0 0 0 0 0];
rf2o = rf2o(:, :) + [-rf2o(1, cid_time) 0 0 map_center(1) map_center(2) 0 0 0 0 0];
map = map(:, :) + [-map(1, cid_time) 0 0 map_center(1) map_center(2) 0 0 0 0 0];

%
if ~save_to_disk
	%figure('Position', [50 50 1024 600], 'DefaultAxesFontSize', 16);
	figure('Position', [50 50 1024 600], 'DefaultAxesFontSize', 12);
end

% Bild des OccupanyGrid laden, normalisieren und invertieren.
map_image = imread(image_file_name);
map_image = 1 - (map_image / 255);

%
for sp = 1:4
	%
	if save_to_disk
		figure('Position', [50 50 1024 600], 'DefaultAxesFontSize', 16);
	else
		% Subplot auswählen
		subplot(subplot_m, subplot_n, sp);	
	end
	
	% Karte anzeigen
	occupancy_grid = robotics.OccupancyGrid(map_image, 1 / map_resolution);
	show(occupancy_grid);
	
	hold on; grid on; grid minor;
	legend('Location','southeast');
	
	% Trajektorien anzeigen
	if sp == 1
		%title('Trajektorie im Map-Koordindatenystem');
		plot(map(:, cid_x), map(:, cid_y), 'k', 'DisplayName', 'Ground Truth');
	elseif sp == 2
		%title('Trajektorie der Robotino Odometrie');
		plot(robo(:, cid_x), robo(:, cid_y), 'r', 'DisplayName', 'Inkrementalgeber');
	elseif sp == 3
		%title('Trajektorie der LSM Odometrie');
		plot(lsm(:, cid_x), lsm(:,cid_y), 'm', 'DisplayName', 'LSM');
	elseif sp == 4
		%title('Trajektorie der RF2O Odometrie');
		plot(rf2o(:, cid_x), rf2o(:, cid_y), 'b', 'DisplayName', 'RF2O');
	else
	end
	
	% Format
	title('');
	xlabel('X [m]');
	ylabel('Y [m]');
	
	% Zoom into Figure
	xlim([9 16]);
	ylim([9 13]);
	
	% Save Figure with Minimal White Space
	% https://de.mathworks.com/help/matlab/creating_plots/save-figure-with-minimal-white-space.html
% 	ax = gca;
% 	outerpos = ax.OuterPosition;
% 	ti = ax.TightInset;
% 	left = outerpos(1) + ti(1);
% 	bottom = outerpos(2) + ti(2);
% 	ax_width = outerpos(3) - ti(1) - ti(3);
% 	ax_height = outerpos(4) - ti(2) - ti(4);
% 	ax.Position = [left bottom ax_width ax_height];
	
	% Save figure
	if save_to_disk
		[file_path, file_name, file_ext] = fileparts(file_name);
		file_saveas = fullfile(file_path, [file_name '_trajectory' num2str(sp)]);
		saveas(gcf, file_saveas, 'png');
	end

end


% figure('Position', [50 50 1024 600], 'DefaultAxesFontSize', 12);
% 
% subplot(1, 2, 1)
% %subplot(subplot_m, subplot_n, 5);
% hold on; grid on; grid minor;
% %legend('Location','northwest');
% legend('Location','northeast');
% xlabel('Zeit [s]');
% ylabel('X [m]');
% %title('X-Achse');
% plot(map(:, cid_time), map(:, cid_x), 'k', 'DisplayName', 'Ground Truth');
% plot(robo(:, cid_time), robo(:, cid_x), 'r', 'DisplayName', 'Inkrementalgeber');
% plot(lsm(:, cid_time), lsm(:, cid_x), 'm', 'DisplayName', 'LSM');
% plot(rf2o(:, cid_time), rf2o(:, cid_x), 'b', 'DisplayName', 'RF2O');
% 
% subplot(1, 2, 2)
% %subplot(subplot_m, subplot_n, 6);
% hold on; grid on; grid minor;
% %legend('Location','northwest');
% legend('Location','northeast');
% xlabel('Zeit [s]');
% ylabel('Y [m]');
% %title('Y-Achse');
% plot(map(:, cid_time), map(:, cid_y), 'k', 'DisplayName', 'Ground Truth');
% plot(robo(:, cid_time), robo(:, cid_y), 'r', 'DisplayName', 'Inkrementalgeber');
% plot(lsm(:, cid_time), lsm(:, cid_y), 'm', 'DisplayName', 'LSM');
% plot(rf2o(:, cid_time), rf2o(:, cid_y), 'b', 'DisplayName', 'RF2O');