function yn = inarange(x, rng, rngType)
% Indicate if the a variable is within a specified range.
%
% Usage: yn = inarange(x, rng)
%
% INPUT:
%  x - scalar or vector.
%  rng - 2-vector, [from to] or [to from].
% Optional:
%  rngType - 1 character string: '(' or '[' - exclusive (default) or inclusive range.
%
% OUTPUT:
%  yn - boolean, size of x.
%
% Examples:
%  inarange(rand(10,1), [0 .5]);
%
% See also: arange().
 
%% Created: 24-Feb-2015 11:16:12
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

%% Parse input:
narginchk(2,3);
if nargin == 2
    rngType = '[';
end

%% Main:
rng = sort(rng);
switch rngType
    case '('
        yn = ( x>rng(1) ) & ( x<rng(2) ); 
    case '['
        yn = ( x>=rng(1) ) & ( x<=rng(2) ); 
    otherwise
        error('Wrong range type.');
end
