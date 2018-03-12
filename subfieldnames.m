function l = subfieldnames(ss, l, root)
% Return a list of fieldnames of the given structure including substructures.
% 
% Example:
% s = struct('a', 1, 'b', 2, 'c', 3, 'ss', struct('a', 4, 'b', 5), 'd', 6, 'e', 7, 'ff', struct('a', 8, 'b', 9)); subfieldnames(s)
    
    if nargin == 1 
        l = {}; 
        root = '';
    end
    
    fnames = fieldnames(ss);
    for ii=1:length(fnames)
        fname = fnames{ii};
        val = ss.(fname);
        if isstruct(val)
            l = subfieldnames(val, l, [fname '.']);
        else
            l = [l [root fname]];
        end
    end
end