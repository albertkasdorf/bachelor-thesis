clear; clc; close all;
format long;
format compact;

% Dreieck berechen
triangle_ru = 1;
triangle_a = (3 * triangle_ru) / sqrt(3);

% Ground Truth der kurzen und langen Seiten des Pentagramms
pentagram_a = 4.5;
pentagram_d = (pentagram_a * (1 + sqrt(5))) / 2;
pentagram_ru = (pentagram_a * sqrt(50 + 10 * sqrt(5))) / 10;
