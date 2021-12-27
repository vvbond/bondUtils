function out = structarrayfun(fun, S)
% Apply a function to an array of structs recursively.
%
% Usage: out = arraystructfun(S)
%
% INPUT:
% fun - handle of the function to apply to the array elements.
% S - array of structs.
%
% OUTPUT:
% out - cellarray of outputs of the function applied to each element.
%
% Examples:
%  arraystructfun(fun, S);
%  [out]=arraystructfun(S);
%
% See also: <other funame>.
 
%% Created: 15-Dec-2021 12:52:25
%% (c) Vladimir Bondarenko, Albus Health.

has_output = true;
if nargout(fun) == 0
    has_output = false;
end

% Decide on output type:
if has_output
    if isempty(S)
        out = [];
        return;
    end
    
    if nargout(fun) ~= 0
        dum = fun(S(1));
        if isscalar(dum) || isempty(dum)
            out = [];
        else
            out = {};
        end
    end
end

% Iterate over array elements:
for s = S(1:end)'
    if has_output
        out = [out, fun(s)];
    else
        fun(s);
    end
    % recurse into substructures:
    for fld = vec(fieldnames(s))'
        fldname = fld{1};
        if isstruct(s.(fldname))
            if has_output
                out = [out, structarrayfun(fun, s.(fldname))];
            else
                structarrayfun(fun,  s.(fldname));
            end
        end
    end
end
