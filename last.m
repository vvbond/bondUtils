function e = last(x)
% Last element in x.
%
% Usage: e = last(x)
%
% INPUT:
% x - Collection of elements.
%
% OUTPUT:
% e - The last element in x.
%
% Examples:
%  last(1:10);
%  e=last('Matlab');
%
% See also: <other funame>.
 
%% Created: 18-Nov-2023 20:23:09

if iscell(x)
    e = x{end};
else
    e = x(end);
end