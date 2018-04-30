function T = memsize(x)
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

nargoutchk(0,1);

if isa(x, 'gpuArray')
    class_x = classUnderlying(x);
else
    class_x = class(x);
end

tokens = regexp(class_x, '^(int|uint)(8|16|32|64)', 'tokens');
if ~isempty(tokens)
    size_bit = str2double(tokens{2});
elseif strcmpi(class_x, 'double')
    size_bit = 64;
elseif strcmpi(class_x, 'single')
    size_bit = 32;
else
    error('memsize: unknown numeric data type.');
end

sz_Bytes = numel(x)*size_bit/8;
sz = sz_Bytes ./ 2.^((0:3)*10);
T = table(sz(1),sz(2),sz(3),sz(4), 'VariableNames', {'Bytes', 'kB', 'MB', 'GB'});
end
