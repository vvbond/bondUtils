function [varargout] = describe(x)
% Descriptive statistics.
%
% Usage: [xmin, xmax, xmean, xstd, xmedian] = describe(x)
%
% INPUT:
%   x - a vector or a matrix.
%
% OUTPUT:
%   none
%  Optional:
%   xmin    - input's minumum value.
%   xmax    - input's maximus value.
%   xmean   - input's average value.
%   xstd    - input's standard deviation.
%   xmedian - input's median value.
%   pk2pk   - input's peak-to-peak variation.
%
% Examples:
%  describe(x);
%  [xmin, xmax, xmean, xstd, xmedian] = describe(x);
%
% See also: range().
 
%% Created: 25-Feb-2015 12:31:27
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

statFuns = {@min, @max, @mean, @median, @std, @(y) max(y)-min(y) };
statNames = {'Min: ', 'Max: ', 'Mean: ', 'Median: ', 'Std: ', 'Peak-to-peak: '};

if nargout == 0
    for ii=1:length(statFuns)
        disp([statNames{ii} num2str( statFuns{ii}( x(:) ) )]);
    end
else
    for ii=1:nargout
        varargout{ii} = statFuns{ii}( x(:) );
    end
end