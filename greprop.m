function newObj = greprop(obj, reg, caseOption)
% Search property names of an object for given pattern.
%
% Usage: newObj = greprop(obj, pattern)
%
% INPUT:
%  obj          - object with multiple properties.
%  reg          - search pattern string.
%
% OUTPUT:
%  newObj       - object of the same class as the input object with only those properties which names satisfy the search pattern.
%
% Examples:
%  shape = struct('width', 5, 'height', 10, 'length', 20); greprop(shape, 'w*th')
%
% See also: .
 
%% Created: 07-Nov-2017 16:33:24
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

        narginchk(2,3);
        if nargin == 2, caseOption = 'ignorecase'; end
        
        props = fieldnames(obj);
        % Search keys:
        ixs = cellfun(@(c) isempty(c), regexpi(props, reg, caseOption) );
        newObj = rmfield(obj, props(ixs));
end
