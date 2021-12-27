function t = datetime2posix(dt, tz)
% Convert time values from datetime to posix format.
%
% Usage: t = datetime2posix(dt)
%
% INPUT:
% dt - datetime values.
%
% OUTPUT:
% t - time values in seconds.
%
% Examples:
%  datetime2posix(dt);
%  [t]=datetime2posix(dt);
%
% See also: <other funame>.
 
%% Created: 17-Dec-2021 18:29:25
%% (c) Vladimir Bondarenko, Albus Health.

narginchk(1,2);
if nargin == 1, tz = 'UTC'; end
t = dt;
t.TimeZone = tz;
t = posixtime(t); 