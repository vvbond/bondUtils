function ds = dirrec(dirname)
% Recursive directory listing.
%
% Usage: ds = recdir(dirname)
%
% INPUT:
% dirname - input directory.
%
% OUTPUT:
% ds - directory structure.
%
% Examples:
%  recdir(dirname);
%  [ds]=recdir(dirname);
%
% See also: <other funame>.
 
%% Created: 14-Dec-2021 18:25:54
%% (c) Vladimir Bondarenko

ds = dir(dirname);
ds(contains({ds.name}, regexpPattern('^\.'))) = [];
if isempty(ds), return; end
ds(1).data = [];

subdir_ind = [ds.isdir];
if isempty(subdir_ind), return; end

for ix = find(subdir_ind)
    name = ds(ix).name;
    folder = ds(ix).folder;
    ds(ix).data = dirrec(fullfile(folder, name));
end