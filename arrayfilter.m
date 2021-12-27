function B = arrayfilter(pred, A)
% Filter array elements.
%
% Usage: B = arrayfilter(pred, A)
%
% INPUT:
% pred - predicate function.
% A - input array.
%
% OUTPUT:
% B - output array.
%
% Examples:
%  arrayfilter(pred, A);
%  [B]=arrayfilter(pred, A);
%
% See also: <other funame>.
 
%% Created: 15-Dec-2021 18:16:01
%% (c) Vladimir Bondarenko, Albus Health.

ind = arrayfun(pred, A);
if ~any(ind)
    B = [];
else
    B = A(ind);
end