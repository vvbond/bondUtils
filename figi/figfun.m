function figfun(fun)
% Run a function for all figures.
%
% Usage: figfun(fun)
%
% INPUT:
%  fun - Handle of the function to run.
%
% OUTPUT:
%  None.
%
% Examples:
%  figfun(fun);
%
% See also: dockfigs.
 
%% Created: 09-Feb-2015 18:20:50
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

figs = get(0,'Children');
figs = sort(figs);
for ii=1:length(figs)
    figure(figs(ii));
    fun();
end
clear figs
