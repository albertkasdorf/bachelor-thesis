close all; clear;
%clc;
format long;
format compact;


map_resolution=0.02;
map_size=[1024 1024];
map_center=(map_size*map_resolution)/2;

% Bild des OccupanyGrid laden, normalisieren und invertieren.
map_image=imread('map.pgm');
map_image=1-map_image/255;

% Ground Truth der Beacon Positionen
% Hinweis: y-Parameter muss umgedreht werden, weil der Ursprung bei MATLAB
% sich unten links befindet.
bgt=[521 554; 523 460; 715 557; 716 463];
bgt=[0 map_size(2)]-bgt;
bgt=bgt.*[-1 1];
bgt=bgt*map_resolution;

map=robotics.OccupancyGrid(map_image,1/map_resolution);
show(map);
hold on;
grid on;
grid minor;


hold on;
m=[0.776 -1.074]+map_center;
C=[1.738939e-04 1.636364e-04;1.636364e-04 1.672474e-04];
error_ellipse(C,m,'conf',0.997,'style','r');
text(0.775785+map_center(1),-1.074339+map_center(2),'#180');

m=[1.175 0.715]+map_center;
C=[4.609576e-03 -2.536788e-03;-2.536788e-03 1.446655e-03];
error_ellipse(C,m,'conf',0.997,'style','r');
text(1.175338,0.715177,'#177');

m=[4.873 -0.070]+map_center;
C=[6.888976e-05 -4.692841e-04;-4.692841e-04 4.751286e-03];
error_ellipse(C,m,'conf',0.997,'style','r');
m=[4.782 0.445]+map_center;
C=[2.610799e-04 -1.049475e-03;-1.049475e-03 4.635274e-03];
error_ellipse(C,m,'conf',0.997,'style','r');
m=[4.649 0.901]+map_center;
C=[6.336682e-04 -1.722673e-03;-1.722673e-03 4.876395e-03];
error_ellipse(C,m,'conf',0.997,'style','r');
m=[4.488 1.304]+map_center;
C=[1.347937e-03 -2.734663e-03;-2.734663e-03 5.663581e-03];
error_ellipse(C,m,'conf',0.997,'style','r');
m=[4.305 1.664]+map_center;
C=[2.924472e-03 -4.681078e-03;-4.681078e-03 7.572546e-03];
error_ellipse(C,m,'conf',0.997,'style','r');
m=[3.267 -4.112]+map_center;
C=[7.735522e-03 6.022407e-03;6.022407e-03 4.724466e-03];
error_ellipse(C,m,'conf',0.997,'style','r');
m=[3.568 -3.832]+map_center;
C=[4.191345e-03 4.010379e-03;4.010379e-03 3.880009e-03];
error_ellipse(C,m,'conf',0.997,'style','r');
m=[3.858 -3.512]+map_center;
C=[2.529285e-03 3.001461e-03;3.001461e-03 3.615761e-03];
error_ellipse(C,m,'conf',0.997,'style','r');
m=[4.139 -3.133]+map_center;
C=[1.605713e-03 2.416868e-03;2.416868e-03 3.711360e-03];
error_ellipse(C,m,'conf',0.997,'style','r');
m=[4.401 -2.687]+map_center;
C=[1.010688e-03 2.013816e-03;2.013816e-03 4.125471e-03];
error_ellipse(C,m,'conf',0.997,'style','r');
m=[4.643 -2.119]+map_center;
C=[6.453949e-04 1.909233e-03;1.909233e-03 5.872332e-03];
error_ellipse(C,m,'conf',0.997,'style','r');
m=[4.903 -0.678]+map_center;
C=[3.177611e-05 2.348057e-04;2.348057e-04 5.841205e-03];
error_ellipse(C,m,'conf',0.997,'style','r');
text(4.719165,-1.090566,'#178');
axis equal;grid on; grid minor;