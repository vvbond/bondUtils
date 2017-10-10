function Y = ts2frames(x, L)
% Fold a time series into frames of given length.
%
% Usage: Y = ts2frames(x, L)
%
% INPUT:
% x - input time series.
% L - frame length.
%
% OUTPUT:
% Y - L-by-k matrix of k frames.
%
% Examples:
%  ts2frames(x, L);
%  [Y]=ts2frames(x, L);
%
% See also: <other funame>.
 
%% Created: 10-Oct-2017 11:52:39
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

k = floor(length(x)/L);
Y = reshape(x(1:k*L), [L, k]);