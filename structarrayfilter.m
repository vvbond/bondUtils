function B = structarrayfilter(pred, S)
% Filter a struct array recursively.
%
% Usage: B = structarrayfilter(pred, S)
%
% INPUT:
% pred - predicate function.
% S - input struct array.
%
% OUTPUT:
% B - output struct array.
%
% Examples:
%  structarrayfilter(pred, S);
%  B = structarrayfilter(pred, S);
%
% See also: arrayfilter(), structarrayfun().
 
%% Created: 15-Dec-2021 18:16:01
%% (c) Vladimir Bondarenko, Albus Health.

B = structarrayfun(@(s) arrayfilter(pred,s), S);