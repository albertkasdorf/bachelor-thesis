clear; clc;
format long;
format compact;

b1=dlmread('b1.csv',';',1,1);	% tof_177_178, tof_177_179
b2=dlmread('b2.csv',';',1,1);	% tof_178_177, tof_178_179
b3=dlmread('b3.csv',';',1,1);	% tof_179_177, tof_179_178
b=dlmread('b.csv',';',1,0);	% tof_179_177, tof_179_178

c0 = physconst('LightSpeed');
unit_of_low_order_bit = 1/(128 * 499.2 * 10^6);

tges_177_178 = mean(b1((b1(:, 2)==178), 3)) / c0;
ttof_177_178 = mean(b1((b1(:, 2)==178), 4)) / c0;

tges_177_179 = mean(b1((b1(:, 2)==179), 3)) / c0;
ttof_177_179 = mean(b1((b1(:, 2)==179), 4)) / c0;

tges_178_179 = mean(b2((b2(:, 2)==179), 3)) / c0;
ttof_178_179 = mean(b2((b2(:, 2)==179), 4)) / c0;

comb_tag_anchor=unique(b(:,2:3),'rows');

for i = 1:size(comb_tag_anchor, 1)
    
    
%    ttof(i)=mean(b(logical((b(:,1)==y(i,1)) .* (b(:, 2)==y(i,2))), 4)) / c0
end

A = [1 1 0; 1 0 1; 0 1 1];
b = [tges_177_178 - ttof_177_178; tges_177_179 - ttof_177_179; tges_178_179 - ttof_178_179];
x = A \ b;

antenna_delay = x / unit_of_low_order_bit;


%https://rechneronline.de/pi/pentagramm.php

%tag_address;anchor_address;ground_truth;range
%177;179;2.0;156.43
%177;178;2.0;156.46

% combnk([177 178 179 180 181],2)

% 177 178     178 177
% 177 179     179 177
% 178 179     179 178
% 
% 177 178     178 177
% 178 179     179 178
% 179 177     177 179

