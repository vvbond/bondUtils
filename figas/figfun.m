function figfun(varargin)
% Run a function for all figures.
%
% Usage: figfun(fun)
%        figfun(fighs, fun)
%
% INPUT:
%  fun - Handle of the function to run.
% Optional:
%  fighs - vector of figure handles.
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

%% Parse the input

narginchk(1,2);

if nargin == 1
    fighs = get(0,'Children');
    fighs = sort(fighs);
    fun = varargin{1};
else
    fighs = varargin{1};
    fun = varargin{2};
end

for ii=1:length(fighs)
    figure(fighs(ii));
    fun(fighs(ii));
end
clear figs
