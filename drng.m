function x = drng(p, m, n)
% discrete random number generation
%
% usage: x = drng(p, m, n)
% INPUT:
% p         : descrete probability distribution function 
% m, n      : size of the output
% OUTPUT:
% x         : m-by-n matrix of random integers sampled from the pdf p.
% 
% Examples: 
% k = 1:100; p = ( sin(2*pi/50*k) + cos(2*pi/30*k) ).^2; p = p/sum(p);
% x = drng(p, 1000, 1); figure; subplot(2,1,1); plot(p); subplot(2,1,2); hist(x,50);
%
% See also: drng2.

error(nargchk(3,3,nargin));
delta = abs(sum(p) - 1);
if delta > .000001
    error('pdf do not some to unity');
end
if ~isempty(find(p<0, 1))
    error('pdf must be nonnegative.')
end

c = cumsum(p);  % cumulative distribution function
N = m*n;
x = rand(N,1);
for ii=1:N
    x(ii) = find(c > x(ii), 1, 'first');
end
x = reshape(x, m, n);