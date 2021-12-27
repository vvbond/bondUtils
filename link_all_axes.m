function link_all_axes(axName)
% Link all the axes in figures.
%
% Usage: link_all_axes(axName)
%
% INPUT:
% axName - string, 'x', 'y', 'xy' (default), or 'off'. Indicates which axis to link.
%
% OUTPUT:
%  None.
%
% Examples:
%  link_all_axes(axName);
%
% See also: linkaxes, gaa, delfigs.
 
%% Created: 18-Mar-2016 17:45:29
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876    

    % Parse input:
    if nargin == 0, axName = 'xy'; end
    
    if ~any( strcmpi(axName, {'x', 'y', 'xy', 'off'}) )
        error('Wrong axis name.');
    end
    
    % Main:
    axs = gaa;
    
    linkaxes(axs, axName);
end