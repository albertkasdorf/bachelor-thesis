clear; clc; close all;
format long;
format compact;

% Daten einlesen
%data = dlmread('los.csv', ';', 1, 0);
%data = dlmread('nlos_water.csv', ';', 1, 0);
%data = dlmread('nlos_metal2.csv', ';', 1, 0);
data = dlmread('nlos_metal.csv', ';', 1, 0);

%
x = (1:length(data(:, 1)))';
figure('DefaultAxesFontSize', 14);
plot(x, data(:, 6), '.r', x, data(:, 13), '.g');
grid on;
legend('range', 'ground\_truth', 'Location','northwest');