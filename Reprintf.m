classdef Reprintf < handle
% Reprint: printf() new text in place of the old one.
%
% Usage: rep = Reprintf; rep.rintf(format, data)
%  where format and data are the same as in fprintf().
%
% Example:
%  rep = Reprintf; for ii=1:10, rep.rintf('Item %d (%d)', ii, 10); pause(.3); end
    properties (Hidden)
        bspStr = sprintf('\b');
        backspace;
    end
    
    methods
        function rpr = Reprintf()
            rpr.backspace = '';
        end
        
        function rintf(rpr, msg, varargin)
            switch nargin
                case 2
                    msgStr = sprintf(msg);
                case 3
                    msgStr = sprintf(msg, varargin{1});
                case 4
                    msgStr = sprintf(msg, varargin{1}, varargin{2});
                case 5
                    msgStr = sprintf(msg, varargin{1}, varargin{2}, varargin{3});
                case 6
                    msgStr = sprintf(msg, varargin{1}, varargin{2}, varargin{3}, varargin{4});
                case 7
                    msgStr = sprintf(msg, varargin{1}, varargin{2}, varargin{3}, varargin{4}, varargin{5});
                case 8
                    msgStr = sprintf(msg, varargin{1}, varargin{2}, varargin{3}, varargin{4}, varargin{5}, varargin{6});
                case 9
                    msgStr = sprintf(msg, varargin{1}, varargin{2}, varargin{3}, varargin{4}, varargin{5}, varargin{6}, varargin{7});
                case 10
                    msgStr = sprintf(msg, varargin{1}, varargin{2}, varargin{3}, varargin{4}, varargin{5}, varargin{6}, varargin{7}, varargin{8});
                case 11
                    msgStr = sprintf(msg, varargin{1}, varargin{2}, varargin{3}, varargin{4}, varargin{5}, varargin{6}, varargin{7}, varargin{8}, varargin{9});
                case 12
                    msgStr = sprintf(msg, varargin{1}, varargin{2}, varargin{3}, varargin{4}, varargin{5}, varargin{6}, varargin{7}, varargin{8}, varargin{9}, varargin{10});
            end
            fprintf([rpr.backspace, msgStr]);
            rpr.backspace = rpr.bspStr(ones(1, length(msgStr)));
        end
    end
end
