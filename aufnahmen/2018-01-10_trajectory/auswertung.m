clear; close all;
%clc;
%format long;

robo = dlmread('robotino_odometry.csv',';',1,0);
lsm = dlmread('lsm_odometry.csv',';',1,0);
rf2o = dlmread('rf2o_odometry.csv',';',1,0);

% Versatz vom Robotino korrigieren
diff = lsm(1:1,4:5)-robo(1:1,4:5);
robo=[robo(:,1:3) robo(:,4:5)+diff robo(:,6:end)];

figure('Position', [50 50 1024 600], 'DefaultAxesFontSize', 16);

subplot(2,2,[1 2]);
hold on; grid on;
legend('Location','southwest');
xlabel('X-Achse in Meter');
ylabel('Y-Achse in Meter');
title('Trajektorie');
plot(robo(:,4), robo(:,5), 'r', 'DisplayName', 'robotino');
plot(lsm(:,4), lsm(:,5), 'g', 'DisplayName', 'lsm');
plot(rf2o(:,4), rf2o(:,5), 'b', 'DisplayName', 'rf2o');
%set(gca,'xdir', 'reverse')

subplot(2,2,3);
hold on; grid on;
legend('Location','northwest');
xlabel('Zeitstempel in Sekunden');
ylabel('X-Achse in Meter');
title('X-Achse');
plot(robo(:,1), robo(:,4), 'r', 'DisplayName', 'robotino');
plot(lsm(:,1), lsm(:,4), 'g', 'DisplayName', 'lsm');
plot(rf2o(:,1), rf2o(:,4), 'b', 'DisplayName', 'rf2o');

subplot(2,2,4);
hold on; grid on;
legend('Location','northwest');
xlabel('Zeitstempel in Sekunden');
ylabel('Y-Achse in Meter');
title('Y-Achse');
plot(robo(:,1), robo(:,5), 'r', 'DisplayName', 'robotino');
plot(lsm(:,1), lsm(:,5), 'g', 'DisplayName', 'lsm');
plot(rf2o(:,1), rf2o(:,5), 'b', 'DisplayName', 'rf2o');
