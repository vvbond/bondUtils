function files = dirscan(dirname, pat)
% Scan directory recursively for files with a given pattern in their name .
%
% Usage: ds = filescan(dirname, pattern)
%
% INPUT:
%  dirname - name of the root directory.
%  pat     - string defining a regex pattern.
%
% OUTPUT:
%  files - struct array.
%
% Examples:
%  dirscan(dirname, pattern);
%  files = dirscan(dirname, pattern);
%
% See also: dirrec, arrayfilter.
 
%% Created: 10-Aug-2023 13:20:49
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

if nargin == 1, pat = '.*'; end
files = [];
ds = dir(dirname);
ds(startsWith({ds.name}, '.')) = [];
if isempty(ds), return; end

files = ds(~[ds.isdir]);

for subdr = ds([ds.isdir])'
    files = [files; dirscan(filename(subdr))];
end

files = arrayfilter(@(f) ~isempty(regexp(filename(f), pat, "once")), files);
