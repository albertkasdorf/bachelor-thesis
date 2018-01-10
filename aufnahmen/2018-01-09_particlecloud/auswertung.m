close all; clear;
%clc;
format long;

%map=robotics.OccupancyGrid(1-imread('map.pgm')/255,1/0.02);
%show(map)

% 1    2   3    4  5 6 7 8  9  10 11
% time;sec;nsec;id;x;y;z;qx;qy;qz;qw
% (B)eacon=66
% (P)ose=80

percent=0.2;

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

data=dlmread('2017-12-18-11-53-54.csv',';',1,0);

% Der Ursprung der Daten war die Bildmitte, daher müssen sie verschoben werden.
data=data+[0 0 0 0 map_center(1) map_center(2) 0 0 0 0 0];

% Daten nach Beacon- und Pose-Positionen trennen
bdata=data(data(:,4)==66,:);
pdata=data(data(:,4)==80,:);

bunique=unique(bdata(:,1));
punique=unique(pdata(:,1));


btimestamp = bunique(round(length(bunique)*percent));

bdata_at_timestamp = bdata(bdata(:,1)==btimestamp,:);


map=robotics.OccupancyGrid(map_image,1/map_resolution);
show(map)
hold on;
grid on;
plot(bdata_at_timestamp(:,5), bdata_at_timestamp(:,6), '*');
plot(bgt(:,1), bgt(:,2), 'r*');
plot(map_center(1), map_center(2), 'rp');
