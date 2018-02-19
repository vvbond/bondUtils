function varargout = memsize(x)
% Size of a variable in memory.
%
% Usage: sz = memsize(x)
%
% INPUT:
% x - A variable.
%
% OUTPUT:
% sz - Size in MB.
%
% Examples:
%  memsize(x);
%  [sz]=memsize(x);
%
% See also: <other funame>.
 
%% Created: 17-Jan-2018 12:45:18
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

if isnumeric(x)
    if isinteger(x)
        tokens = regexp(class(x), '^(int|uint)(8|16|32|64)', 'tokens');
        size_bit = str2double(tokens{2});
    elseif strcmpi(class(x), 'double')
        size_bit = 64;
    elseif strcmpi(class(x), 'single')
        size_bit = 32;
    else
        error('memsize: unknown numeric data type.');
    end
    
    sz_Bytes = numel(x)*size_bit/8;
    sz_MB = sz_Bytes/2^20;
    sz_GB = sz_Bytes/2^30;
    sz = sz_GB;
    
    disp([sz_MB sz_GB]);
else
    warning('memsize: not numeric data not supported yet');
    sz = [];
end
