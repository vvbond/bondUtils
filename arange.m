function minAmax = arange(A)
% Another range returns the minimum and maximum value of the input.
%
% Usage: [minA, maxA] = arange(A)
%
% INPUT:
%  A - matrix or vector.
%
% OUTPUT:
%  mina - minimum element of A.
%  maxa - maximum element of A.
%
% Examples:
%  arange(A);
%  [minA, maxA] = arange(A);
%
% See also: vec().
 
%% Created: 12-Feb-2015 09:51:06
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

minAmax = [min(A(:)) max(A(:))];