function yn = within(x, interval, mode)
% Indicate which vector elements lie within a specified interval.
%
% Usage: yn = within(x, rng)
%
% INPUT:
%  x        - scalar or vector.
%  interval - 2-vector, [from to] or [to from].
% Optional:
%  mode     - character string specifying range type, default '[':
%            '('    - exclusive on both sides, 
%            '['    - inclusive on both sides,
%            '[)'   - inclusive on the left, exclusive on the right,
%            '(]'   - exclusive on the right, inclusive on the left.
%
% OUTPUT:
%  yn - boolean, size of x.
%
% Examples:
%  within(rand(10,1), [0 .5])
%
% See also: arange().
 
%% Created: 24-Feb-2015 11:16:12
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

%% Parse input:
narginchk(2,3);
if nargin == 2
    mode = '[';
end

%% Main:
interval = sort(interval);
switch mode
    case '('
        yn = x >  interval(1) & x <  interval(2); 
    case '['
        yn = x >= interval(1) & x <= interval(2); 
    case '[)'
        yn = x >= interval(1) & x < interval(2);
    case '(]'
        yn = x >  interval(1) & x <=interval(2); 
    otherwise
        error('Wrong range type.');
end