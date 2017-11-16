function s = flattenstruct(ss, s)
% Extract sub-structure fields.
% 
% Example:
% s = struct('a', 1, 'b', 2, 'c', 3, 'ss', struct('d', 4, 'e', 5)); flattenstruct(s)
    
    if nargin == 1, s = struct(); end
    
    fnames = fieldnames(ss);
    for ii=1:length(fnames)
        val = ss.(fnames{ii});
        if isstruct(val)
            s = flattenstruct(val, s);
        else
            s.(fnames{ii}) = val;
        end
    end
end