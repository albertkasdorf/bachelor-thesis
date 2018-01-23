clear; clc; close all;
format long;
format compact;

% Column ID Tag/Anker
cid_t = 4;
cid_a = 5;
cid_r = 6;
cid_gt = 7;

% Daten einlesen
data_uncab = dlmread('uncalibrated.csv', ';', 1, 0);
data_lgs = dlmread('calibrated_with_lgs.csv', ';', 1, 0);
data_dw = dlmread('calibrated_with_decawave.csv', ';', 1, 0);

% Eindeutige Tag/Anker kombinationen
comb_ta = unique(data_uncab(:, [cid_t, cid_a]), 'rows');
uniq_ta = unique(data_uncab(:, [cid_t, cid_a]));

%
uncab = [];
lgs = [];
dw = [];

% Durch jede Zeile iterieren
for i = 1:size(comb_ta, 1)
    
    % Tag/Anker-Kombination bestimmen
    id_t = comb_ta(i, 1);
    id_a = comb_ta(i, 2);
    
    %----------------------------------------------------------------------
    % Selektiere alle Daten zu der Tag/Anker-Kombination
    data_selector = logical((data_uncab(:, cid_t) == id_t) .* (data_uncab(:, cid_a) == id_a));
    uncab_data = data_uncab(data_selector, cid_r);
    uncab_mean = mean(uncab_data);
    uncab_std = std(uncab_data);
    uncab_min = min(uncab_data);
    uncab_max = max(uncab_data);
    uncab_gt = mean(data_uncab(data_selector, cid_gt));
    uncab = [uncab; id_t id_a uncab_gt uncab_mean uncab_std uncab_min uncab_max];
    
    %----------------------------------------------------------------------
    % Selektiere alle Daten zu der Tag/Anker-Kombination
    data_selector = logical((data_lgs(:, cid_t) == id_t) .* (data_lgs(:, cid_a) == id_a));
    lgs_data = data_lgs(data_selector, cid_r);
    lgs_mean = mean(lgs_data);
    lgs_std = std(lgs_data);
    lgs_min = min(lgs_data);
    lgs_max = max(lgs_data);
    lgs_gt = mean(data_lgs(data_selector, cid_gt));
    lgs = [lgs; id_t id_a lgs_gt lgs_mean lgs_std lgs_min lgs_max];
    
    %----------------------------------------------------------------------
    % Selektiere alle Daten zu der Tag/Anker-Kombination
    data_selector = logical((data_dw(:, cid_t) == id_t) .* (data_dw(:, cid_a) == id_a));
    dw_data = data_dw(data_selector, cid_r);
    dw_mean = mean(dw_data);
    dw_std = std(dw_data);
    dw_min = min(dw_data);
    dw_max = max(dw_data);
    dw_gt = mean(data_dw(data_selector, cid_gt));
    dw = [dw; id_t id_a dw_gt dw_mean dw_std dw_min dw_max];
end

fprintf('LaTeX Tabelle:\n');
fprintf('Kalibrierungsart & Von & Nach & Entfernung & $\\overline{x}_{arithm}$ & $\\sigma$ & Min & Max \\\\\n');
fprintf('\\hline\n');
fprintf('Keine & %d & %d & %.3f & %.3f & %.3f & %.3f & %.3f \\\\\n', uncab');
fprintf('\\hline\n');
fprintf('LGS & %d & %d & %.3f & %.3f & %.3f & %.3f & %.3f \\\\\n', lgs');
fprintf('\\hline\n');
fprintf('DecaWave & %d & %d & %.3f & %.3f & %.3f & %.3f & %.3f \\\\\n', dw');
fprintf('\\hline\n');
