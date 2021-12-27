function out = interval_shift(in, frac)
% Shift an interval by given fraction of its width.
%
% Usage: interval = interval_shift(interval, frac)
%
% INPUT:
% in - input interval
% frac - shift coefficient as fraction of the input width.
%
% OUTPUT:
% out - expanded interval.
%
% Examples:
%  interval = interval_shift(interval, frac);
%
% See also: interval_midpoint(), interval_resize().
 
%% Created: 18-Dec-2021 18:55:28
%% (c) Vladimir Bondarenko, Albus Health.

shift = diff(in)*frac;
out = in + shift;