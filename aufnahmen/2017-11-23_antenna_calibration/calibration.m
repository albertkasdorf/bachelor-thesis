clear; clc;
format long;
format compact;

c0 = physconst('LightSpeed');
unit_of_low_order_bit = 1 / (128 * 499.2 * 10^6);

% Column ID Tag/Anker
cid_t = 2;
cid_a = 3;
cid_r = 5;

% Ground Truth der kurzen und langen Seiten des Pentagramms
gt_a = 5.01;
gt_d = (gt_a * (1 + sqrt(5))) / 2;
gt = [
    177, 178, 2.0; 177, 179, 2.0;
    178, 177, 2.0; 178, 179, 2.0;
    179, 177, 2.0; 179, 178, 2.0;
];

% Umkreisradius des Pentagramms
r_u = (gt_a * sqrt(50 + 10 * sqrt(5))) / 10;

% LGS Komponenten
A = [];
x = [];
b = [];

% Daten einlesen
data = dlmread('b.csv', ';', 1, 0);

% Eindeutige Tag/Anker kombinationen
comb_ta = unique(data(:, [cid_t, cid_a]), 'rows');
uniq_ta = unique(data(:, [cid_t, cid_a]));

% Durch jede Zeile iterieren
for i = 1:size(comb_ta, 1)
    
    % Tag/Anker-Kombination bestimmen
    id_t = comb_ta(i, 1);
    id_a = comb_ta(i, 2);
        
    %----------------------------------------------------------------------
    % Selektiere alle Ground Truth Daten zu der Tag/Anker-Kombination
    gt_selector = logical((gt(:, 1) == id_t) .* (gt(:, 2) == id_a));
    tges = gt(gt_selector, 3) / c0;
    
    %----------------------------------------------------------------------
    % Selektiere alle Daten zu der Tag/Anker-Kombination
    data_selector = logical((data(:, cid_t) == id_t) .* (data(:, cid_a) == id_a));
    data_select = data(data_selector, cid_r);
    
    % Mittelwert der selektierten Daten bilden und in Sekunden umrechnen.
    tof = mean(data_select) / c0;
    
    %----------------------------------------------------------------------
    b = [b; abs(tges - tof)];
    
    %----------------------------------------------------------------------
    A_row = logical((uniq_ta == id_t) + (uniq_ta == id_a));
    A = [A; A_row'];
end

% Gleichungssytem lösen
x = A \ b;

% Antennenverzögerung berechnen
antenna_delay = x / unit_of_low_order_bit;

% Ausgabe
fprintf('tag_id = %d with antenna_delay = %f\n', [uniq_ta'; antenna_delay']);
