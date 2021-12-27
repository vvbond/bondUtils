function axs = gaa()
% Get all axes in all figures.
%
% Usage: axs = gaa()
%
% INPUT:
%  None.
%
% OUTPUT:
% axs - Array of axes handles.
%
% Examples:
%  gaa();
%  axs = gaa();
%
% See also: delfigs, link_all_axes.
 
%% Created: 18-Mar-2016 17:50:39
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

axs = findall(get(0,'Children'), 'Type', 'Axes');