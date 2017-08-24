function fhelp = get_help(mfile)
% Extract help lines from a given function or class.
    
    fid = fopen(which(mfile), 'r');
    tline = fgetl(fid);
    fhelp = {};
    ii = 1;
    while ischar(tline)
        if ~isempty(regexp(tline, '^\s*%|^\s*function|^s*classdef', 'once'))
            fhelp{ii,1} = tline;
            ii = ii+1;
            tline = fgetl(fid);
        else
            break;
        end
    end
    fclose(fid);
end