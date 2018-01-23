clear; clc; close all;
format long;
format compact;

c0 = physconst('LightSpeed');
unit_of_low_order_bit = 1 / (128 * 499.2 * 10^6);

% Column ID Tag/Anker
cid_t = 4;
cid_a = 5;
cid_r = 6;

% Wie groß ist die Population und wie oft soll diese Ausgewertet werden?
candidate_count = 100;  %1000
iterations = 200;       %100

inital_delay = 513 * 10^-9;
inital_range = 6 * 10^-9;
inital_quality = 0;
pertubation_limit = 0.2 * 10^-9;

% Daten einlesen
data = dlmread('data.csv', ';', 1, 0);

% Eindeutige Tag/Anker kombinationen
comb_ta = unique(data(:, [cid_t, cid_a]), 'rows');
uniq_ta = unique(data(:, [cid_t, cid_a]));
count_ta = length(uniq_ta);

% Zeile->Spalte; (Zeile, Spalte); z1->s1; z1->s2; z1->s3; ...
gt_a = 4.5;
gt_d = (gt_a * (1 + sqrt(5))) / 2;
edm_actual = [
    0 gt_a gt_d gt_d gt_a;
    gt_a 0 gt_a gt_d gt_d;
    gt_d gt_a 0 gt_a gt_d;
    gt_d gt_d gt_a 0 gt_a;
    gt_a gt_d gt_d gt_a 0;
];
edm_measured = zeros(length(uniq_ta));

tof_actual = [];
tof_measured = [];

candidates = [];

%--------------------------------------------------------------------------
% Füllen der edm_measured Matrix
for i = 1:size(comb_ta, 1)      % Durch jede Zeile von comb_ta iterieren
    
    % Tag/Anker-Kombination bestimmen
    id_t = comb_ta(i, 1);
    id_a = comb_ta(i, 2);
    
    % Position der Zelle bestimmen
    idx_r = find(uniq_ta == id_t);
    idx_c = find(uniq_ta == id_a);
    
    %----------------------------------------------------------------------
    % Selektiere alle Daten zu der Tag/Anker-Kombination
    data_selector = logical((data(:, cid_t) == id_t) .* (data(:, cid_a) == id_a));
    data_select = data(data_selector, cid_r);
    
    % Mittelwert der selektierten Daten bilden und in Sekunden umrechnen.
    edm_measured(idx_r, idx_c) = mean(data_select);
end

% Convert measured ranges to times.
tof_actual = edm_actual / c0;
tof_measured = edm_measured / c0;

%--------------------------------------------------------------------------
% Wie oft soll die Population ausgewertet werden?
for i = 1:iterations
    
    %----------------------------------------------------------------------
    % Population erstellen
    if isempty(candidates)
        a = inital_delay;
        b = inital_range;
        
        candidates = a + (b - a) .* rand(candidate_count, count_ta + 1);
    else
        best25_count = ceil(candidate_count * 0.25);
        best25 = candidates(1:best25_count, :);
        candidates = best25;
        
        for i_b = 1:3
            a = best25 - pertubation_limit;
            b = best25 + pertubation_limit;
            candidates_new = a + (b - a) .* rand(size(best25));
            candidates = [candidates; candidates_new];
        end 
        
        candidates = candidates(1:candidate_count, :);
    end
    candidates(:, end) = inital_quality;
    
    % Every 20 iterations halve the perturbation limits
    if mod(i, 20) == 0
        pertubation_limit = pertubation_limit / 2;
    end
    
    
    %----------------------------------------------------------------------
    % Population bewerten
    for i_c = 1:candidate_count
        del_chip1 = ones([count_ta 1]) * candidates(i_c, 1:end-1);
        del_chip1 = del_chip1 .* not(logical(eye(count_ta)));
        del_chip2 = del_chip1';
        
        tof_candidate = 0.5 * del_chip1 + 0.5 * del_chip2 + tof_measured;
        norm_candidate = norm(tof_actual - tof_candidate);
        candidates(i_c, end) = norm_candidate;
    end
    candidates = sortrows(candidates, count_ta + 1, 'descend');
end

%----------------------------------------------------------------------
% Ausgabe
output = [uniq_ta'; candidates(1, 1:end-1) / (2*unit_of_low_order_bit)];
fprintf('tag_id = %d with antenna_delay = %f\n', output);






