clear; clc; close all;
format long;
format compact;

% Column ID Tag/Anker
cid_t = 4;
cid_a = 5;
cid_r = 6;
cid_gt = 7;

% Daten einlesen
%data = dlmread('uncalibrated.csv', ';', 1, 0);
data = dlmread('calibrated_with_lgs.csv', ';', 1, 0);
%data = dlmread('calibrated_with_decawave.csv', ';', 1, 0);

% Eindeutige Tag/Anker kombinationen
comb_ta = unique(data(:, [cid_t, cid_a]), 'rows');
uniq_ta = unique(data(:, [cid_t, cid_a]));

rMin=min(data(:, cid_r));
rMax=max(data(:, cid_r));

% Durch jede Zeile iterieren
for i = 1:size(comb_ta, 1)
    clf;
    
    % Tag/Anker-Kombination bestimmen
    id_t = comb_ta(i, 1);
    id_a = comb_ta(i, 2);
    
    %----------------------------------------------------------------------
    % Selektiere alle Daten zu der Tag/Anker-Kombination
    data_selector = logical((data(:, cid_t) == id_t) .* (data(:, cid_a) == id_a));
    data_selected = data(data_selector, cid_r);
    
    % Histogram
    %figure;
	h=histogram(data_selected, 20,'Normalization','pdf');
	hold on;
	
	% Gaußkurve
	%rMin=min(data_selected);
	%rMax=max(data_selected);
	rMu=mean(data_selected);
	rSigma=std(data_selected);
	y=rMin:0.001:rMax;
	f=exp(-(y-rMu).^2./(2*rSigma^2))./(rSigma*sqrt(2*pi));
	plot(y,f,'r-','LineWidth',1.5);
	
	% Diagramm option
	%set(gca, 'FontSize', 14)	% Default 12
	grid on;
	grid minor;
	%xlabel('Gemessene Entfernung in Meter');
	%ylabel('Anzahl der Messungen');
	legend('Histogramm', 'PDF', 'Location', 'northeast');
	ylim([0 45]);
	xlim([rMin rMax]);
	xtickangle(45);
	xtickformat('%.2f');
    title(sprintf('Tag: %d <-> Anker: %d', id_t, id_a));
    
    % export diagram
    name=['calibration_histogram_', num2str(id_t), '_', num2str(id_a)];
	filename_export=fullfile('/home/albert/Documents/bachelor-thesis/aufnahmen/2018-01-22_antenna_calibration',strcat(name,'.png'));
	saveas(gcf,filename_export);
    
end
