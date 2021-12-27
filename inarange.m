function yn = inarange(x, rng, rngType)
% Indicate if the a variable is within a specified interval.
%
% Usage: yn = inarange(x, rng)
%
% INPUT:
%  x - scalar or vector.
%  rng - 2-vector, [from to] or [to from].
% Optional:
%  rngType - character string specifying range type, default '[':
%            '('    - exclusive on both sides, 
%            '['    - inclusive on both sides,
%            '[)'   - inclusive on the left, exclusive on the right,
%            '(]'   - exclusive on the right, inclusive on the left.
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
        yn = x >  rng(1) & x <  rng(2); 
    case '['
        yn = x >= rng(1) & x <= rng(2); 
    case '[)'
        yn = x >= rng(1) & x < rng(2);
    case '(]'
        yn = x >  rng(1) & x <=rng(2); 
    otherwise
        error('Wrong range type.');
end