function dirs = getdirs(dirname, sortField)
% Get a list of directories in the given directory.
%
% Usage: dirs = getdir(dirname)
%
% INPUT:
%  dirname      - Root directory.
%  sortField    - (optional) name of the field to sort. Default, 'name'
%
% OUTPUT:
%  dirs - Array of structures representing the sub-directories.
%
% Examples:
%  dirs = getdir(dirname);
%
% See also: <other funame>.
 
%% Created: 11-May-2016 18:07:49
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

% Defaults:
switch nargin
    case 0
        dirname = pwd;
        sortField = 'name';
    case 1
        sortField = 'name';
end

% Main:
dirs = [];
dum = dir(dirname);
for ii=1:length(dum)
    if dum(ii).isdir && ~any(strcmpi(dum(ii).name, {'.', '..'}))
        dirs = [dirs dum(ii)];
    end
end

%% Sort
[~, sort_ix] = sort([dirs.(sortField)]);
dirs = dirs(sort_ix);