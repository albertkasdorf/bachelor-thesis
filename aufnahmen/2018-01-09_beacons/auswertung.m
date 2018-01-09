 clear; clc;
 
 data=dlmread('data.csv',';',2,0);
 bids=unique(data(1:end,4));
 
 figure;
 hold on;
 grid on;
 grid minor on;
  
 for bid = bids'
  bindex=(data(:,4)==bid);
  bdata=data(bindex,:);
  plot(bdata(:,1),bdata(:,5),'*');
 end