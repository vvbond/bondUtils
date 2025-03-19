function ds = dirrec(dirname)
% Recursive directory listing.
%
% Usage: ds = dirrec(dirname)
%
% INPUT:
% dirname - input directory.
%
% OUTPUT:
% ds - directory structure.
%
% Examples:
%  dirrec(dirname);
%  [ds]=dirrec(dirname);
%
% See also: <other funame>.
 
%% Created: 14-Dec-2021 18:25:54
%% (c) Vladimir Bondarenko

ds = dir(dirname);
ds(contains({ds.name}, regexpPattern('^\.'))) = [];
if isempty(ds), return; end
ds(1).data = [];

for ix = find([ds.isdir])
    ds(ix).data = dirrec(filename(ds(ix)));
end