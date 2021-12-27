function y = getitem(x, ix)
% Return y = x(ix) or y = x{ix}.
%
% Usage: y = getitem(x, ix)
%
% INPUT:
% x - an array.
% ix - index of the element to get.
%
% OUTPUT:
% y - the ix's element of x.
%
% Examples:
%  getitem(x, ix);
%  y = getitem(x, ix);
%
% See also: <other funame>.
 
%% Created: 20-Dec-2021 17:36:05
%% (c) Vladimir Bondarenko, Albus Health.

if iscell(x)
    y = x{ix};
else
    y = x(ix);
end