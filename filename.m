function fname = filename(f)
% Build a filename 

if isstruct(f) && isfield(f, 'name') && isfield(f, 'folder')
    fname = fullfile(f.folder, f.name);
elseif ischar(f)
    fname = f;
end

end