function out = interval_resize(in, frac)
% Resize an interval by given fraction.
%
% Usage: interval = interval_resize(frac)
%
% INPUT:
% in - input interval
% frac - expansion coefficient as fraction of the input width.
%
% OUTPUT:
% out - expanded interval.
%
% Examples:
%  interval = interval_expand(interval, frac);
%
% See also: interval_midpoint.
 
%% Created: 18-Dec-2021 18:55:28
%% (c) Vladimir Bondarenko, Albus Health.

c = interval_midpoint(in);
width = diff(in)*frac;
out = [c - width/2, c + width/2];