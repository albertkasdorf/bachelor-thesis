%
% Vizualisieren der Unterschied zwischen der Robotino-/rf2o- und lsm-Odometrie.
%
close all; clear; clc;
format long; format compact;

% Konstanten
cid_time = 1;
cid_x = 4;
cid_y = 5;

subplot_m = 3;
subplot_n = 2;
subplot_count = (subplot_m * subplot_n);

% Kartenparameter
map_resolution = 0.02;
map_size = [1024 1024];
map_center = (map_size * map_resolution) / 2;

% Dateipfad
odom_file_name = 'Record_2018-02-08-12-30-43_odom';
%odom_file_name = 'Record_2018-02-08-12-33-53_odom';
map_file_name = 'Record_2018-02-08-12-30-43_map';
%map_file_name = 'Record_2018-02-08-12-33-53_map';

robo_file_name = strcat(odom_file_name, '_robotino.csv');
lsm_file_name = strcat(odom_file_name, '_lsm.csv');
rf2o_file_name = strcat(odom_file_name, '_rf2o.csv');
map_file_name = strcat(map_file_name, '_robotino.csv');

%
robo = dlmread(robo_file_name, ';', 1, 0);
lsm = dlmread(lsm_file_name, ';', 1, 0);
rf2o = dlmread(rf2o_file_name, ';', 1, 0);
map = dlmread(map_file_name, ';', 1, 0);

%
robo = robo(:, :) + [0 0 0 map_center(1) map_center(2) 0 0 0 0 0];
lsm = lsm(:, :) + [0 0 0 map_center(1) map_center(2) 0 0 0 0 0];
rf2o = rf2o(:, :) + [0 0 0 map_center(1) map_center(2) 0 0 0 0 0];
map = map(:, :) + [0 0 0 map_center(1) map_center(2) 0 0 0 0 0];

%
%figure('Position', [50 50 1024 600], 'DefaultAxesFontSize', 16);
figure('Position', [50 50 1024 600], 'DefaultAxesFontSize', 12);

% Bild des OccupanyGrid laden, normalisieren und invertieren.
map_image = imread('fh_g300_right.pgm');
map_image = 1 - (map_image / 255);

%
for sp = 1:4
	
	% Subplot auswählen
	subplot(subplot_m, subplot_n, sp);
	
	% Karte anzeigen
	occupancy_grid = robotics.OccupancyGrid(map_image, 1 / map_resolution);
	show(occupancy_grid);
	
	hold on; grid on; grid minor;
	legend('Location','southwest');
	
	% Trajektorien anzeigen
	if sp == 1
		title('Trajektorie im Map-Koordindatenystem');
		plot(map(:, cid_x), map(:, cid_y), 'k', 'DisplayName', 'Map');
	elseif sp == 2
		title('Trajektorie der Robotino Odometrie');
		plot(robo(:, cid_x), robo(:, cid_y), 'r', 'DisplayName', 'Robotino');
	elseif sp == 3
		title('Trajektorie der LSM Odometrie');
		plot(lsm(:, cid_x), lsm(:,cid_y), 'g', 'DisplayName', 'LSM');
	elseif sp == 4
		title('Trajektorie der RF2O Odometrie');
		plot(rf2o(:, cid_x), rf2o(:, cid_y), 'b', 'DisplayName', 'RF2O');
	else
	end
	
	% Zoom into Figure
	xlim([9 16]);
	ylim([9 13]);	
end


%figure('Position', [50 50 1024 600], 'DefaultAxesFontSize', 12);

%subplot(1, 2, 1)
subplot(subplot_m, subplot_n, 5);
hold on; grid on;
legend('Location','northwest');
xlabel('Zeitstempel in Sekunden');
ylabel('X-Achse in Meter');
title('X-Achse');
plot(map(:, cid_time), map(:, cid_x), 'k', 'DisplayName', 'Map');
plot(robo(:, cid_time), robo(:, cid_x), 'r', 'DisplayName', 'Robotino');
plot(lsm(:, cid_time), lsm(:, cid_x), 'g', 'DisplayName', 'LSM');
plot(rf2o(:, cid_time), rf2o(:, cid_x), 'b', 'DisplayName', 'RF2O');

%subplot(1, 2, 2)
subplot(subplot_m, subplot_n, 6);
hold on; grid on;
legend('Location','northwest');
xlabel('Zeitstempel in Sekunden');
ylabel('Y-Achse in Meter');
title('Y-Achse');
plot(map(:, cid_time), map(:, cid_y), 'k', 'DisplayName', 'Map');
plot(robo(:, cid_time), robo(:, cid_y), 'r', 'DisplayName', 'Robotino');
plot(lsm(:, cid_time), lsm(:, cid_y), 'g', 'DisplayName', 'LSM');
plot(rf2o(:, cid_time), rf2o(:, cid_y), 'b', 'DisplayName', 'RF2O');





% Versatz vom Robotino korrigieren
%diff = lsm(1:1,4:5)-robo(1:1,4:5);
%robo=[robo(:,1:3) robo(:,4:5)+diff robo(:,6:end)];

% figure('Position', [50 50 1024 600], 'DefaultAxesFontSize', 16);
% 
% subplot(2,2,[1 2]);
% hold on; grid on;
% legend('Location','southwest');
% xlabel('X-Achse in Meter');
% ylabel('Y-Achse in Meter');
% title('Trajektorie');
% plot(robo(:,4), robo(:,5), 'r', 'DisplayName', 'robotino');
% plot(lsm(:,4), lsm(:,5), 'g', 'DisplayName', 'lsm');
% plot(rf2o(:,4), rf2o(:,5), 'b', 'DisplayName', 'rf2o');
% %set(gca,'xdir', 'reverse')
% 
% subplot(2,2,3);
% hold on; grid on;
% legend('Location','northwest');
% xlabel('Zeitstempel in Sekunden');
% ylabel('X-Achse in Meter');
% title('X-Achse');
% plot(robo(:,1), robo(:,4), 'r', 'DisplayName', 'robotino');
% plot(lsm(:,1), lsm(:,4), 'g', 'DisplayName', 'lsm');
% plot(rf2o(:,1), rf2o(:,4), 'b', 'DisplayName', 'rf2o');
% 
% subplot(2,2,4);
% hold on; grid on;
% legend('Location','northwest');
% xlabel('Zeitstempel in Sekunden');
% ylabel('Y-Achse in Meter');
% title('Y-Achse');
% plot(robo(:,1), robo(:,5), 'r', 'DisplayName', 'robotino');
% plot(lsm(:,1), lsm(:,5), 'g', 'DisplayName', 'lsm');
% plot(rf2o(:,1), rf2o(:,5), 'b', 'DisplayName', 'rf2o');
