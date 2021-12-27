function p = interval_midpoint(interval)
% Midpoint of an interval.
%
% Usage: p = interval_midpoint(interval)
%
% INPUT:
%  interval - 2-vector defining an interval.
%
% OUTPUT:
%  p - centerpoint of the interval.
%
% Examples:
%  interval_midpoint(interval);
%  p = interval_midpoint(interval);
%
% See also: <other funame>.
 
%% Created: 18-Dec-2021 18:44:49
%% (c) Vladimir Bondarenko, Albus Health.

p = interval(1) + diff(interval)/2;