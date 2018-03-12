function node = getsubfield(g, nname)
    npath = strsplit(nname, '.');
    node = g;
    for ii=1:length(npath)
        node = node.(npath{ii});
    end
end