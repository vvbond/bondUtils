function xy = drng2(p2, N)
% discrete random number generation in 2D.
%
% usage: x = drng(p2, m, n)
% INPUT:
% p2        : descrete 2D pdf
% N         : number of random points 
% OUTPUT:
% xy        : N-by-2 matrix of random integers sampled from the pdf p2.
% 
% Examples:
% 
% See also: drng.

error(nargchk(2,2,nargin));
delta = abs(sum(p2(:)) - 1);
if delta > .000001
    error('pdf do not some to unity');
end
if ~isempty(find(p2<0, 1))
    error('pdf must be nonnegative.')
end

xy = zeros(N,2);

px = sum(p2);      % marginal pdf_x
% Generate N random realization of x
xy(:,1) = drng(px, N, 1);
% generate N random (conditional) realization of y
for ii=1:N
    px_y = p2(:, xy(ii, 1)); % conditional pdf for y given x
    px_y = px_y/sum(px_y);    % normalize
    cx_y = cumsum(px_y);
    xy(ii, 2) = find(cx_y > rand, 1, 'first');
end

