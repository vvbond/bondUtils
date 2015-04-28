function a = vec(A)
% Vectorize a matrix by column stacking.
%
% Usage: a = vec(A)
%
% INPUT:
% A - m-by-n matix.
%
% OUTPUT:
% a - m*n-by-1 vector.
%
% Examples:
%  vec(A);
%  a=vec(A);
%
% See also: <other funame>.
 
%% Created: 02-Feb-2015 17:00:33
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

a = A(:);
