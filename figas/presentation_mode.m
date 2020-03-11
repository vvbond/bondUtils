function presentation_mode(hfig)
% Put a figure into a presentation mode.
%
% Usage: presentation_mode(hfig)
%
% INPUT:
% hfig - figure handle.
%
% OUTPUT:
%  None.
%
% Examples:
%  presentation_mode(hfig);
%  []=presentation_mode(hfig);
%
% See also: <other funame>.
    if nargin == 0, hfig = gcf; end
    haxs = findobj(hfig, 'Type', 'Axes');
    
    for hax = haxs(:)'
        set(hax, 'FontSize', 14);
    end
    end
    
 
%% Created: 11-Mar-2020 17:56:50