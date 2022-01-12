function opts = parse_keyvals(varargin)
% Parse key-value pairs.
%
% Usage: opts = parse_keyvals(key, value, ...)
%        opts = parse_keyvals(opt
%
% INPUT:
%  opts  - struct of default options.
%  key   - key name.
%  value - key value.
%
% OUTPUT:
%  opts - struct with opt.(key) = value.
%
% Examples:
%  opts = parse_keyvals('foo', 1, 'bar', 2);
%  opts = struct('foo', 1, 'bar', 2, 'baz', 0); opts = parse_keyvals(opts, 'baz', 42);
%
% See also: <other funame>.
 
%% Created: 12-Jan-2022 17:42:56
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

i0 = 1;
opts = struct();
if mod(length(varargin),2)
    if isstruct(varargin{1})
        opts = varargin{1};
        i0 = 2;
    else
        error('%s: Number of key-value arguments must be even.'); 
    end
end

for ii=i0:2:length(varargin)
    key = varargin{ii};
    val = varargin{ii+1};
    opts.(key) = val;
end