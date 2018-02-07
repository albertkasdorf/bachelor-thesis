function y = linear_mapping(x, in, out)
% function for linear mapping between two ranges
% https://machinelearning1.wordpress.com/2014/07/13/linear-vector-mapping-scaling-matlab/
% usage:
% >> linmap(0.1, [0 1], [1 1146]);
%
	a = in(1);
	b = in(2);
	c = out(1); d = out(2);
	y = ((c + d) + (d - c) * ((2 * x - (a + b)) / (b - a))) / 2;
end