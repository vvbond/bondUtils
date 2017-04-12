classdef FunPrint < handle
% FunPrint: enhanced functionality of fprintf.
%
% Usage: fprint = FunPrint; frpint.over(format, data)
%  where format and data are the same as in fprintf().
%
% Examples:
%  fprint = FunPrint; for ii=1:10, fprint.over('Item %d (%d)\n', ii, 10); pause(.3); end
%  a = rand(1,3); FunPrint.vector('A random vector: %1.2f\n', a);

    properties (Hidden)
        bspStr = sprintf('\b');
        backspace;
    end
    
    methods
        function fpr = FunPrint()
            fpr.backspace = '';
        end
        
        function over(fpr, msg, varargin)
            msgStr = FunPrint.sprintf_cell(msg, varargin);
            fprintf([fpr.backspace, msgStr]);
            fpr.backspace = fpr.bspStr(ones(1, length(msgStr)));
        end
        
    end
    
    %% Static methods
    methods(Static)
        function vector(msg, varargin)
        % Print out a vector.
        %
        % Usage:
        % INPUT:
        % OUTPUT:
        %
        % Example:
        %   FunPrint.vector('Consider two 3D points: %2.1f and %2.0f.\n', [1 2 3], [3 2 1]');
            
            % Sanity check:
            narginchk(2,inf);
            if ~ischar(msg), error('Wrong argument type. The first argument must be a string.'); end
            for ii=1:length(varargin)
                v = varargin{ii};
                if ~(isnumeric(v) && isvector(v)), error('Wrong type of the argument #%d. Vector is expected.', ii+2); end
            end
            
            % Find the format specifications:
            format_pattern = '%[-+\s0#]?\d+\.?\d*[diuoxXfeEgG]'; % <flag><field width><numeric conversion>
            [frmts, msg_split] = regexpi(msg, format_pattern, 'match', 'split');
            if isempty(frmts)
                error('The message doesn''t contain a format string.')
            elseif numel(frmts) < length(varargin)
                error('Number of vectors is less then the number of specified formats.');
            else
                % Expand format strings:
                for ii=1:length(varargin)
                    n = length(varargin{ii});
                    frmts{ii} = repmat([frmts{ii} ' '], 1, n);      % Add a space between vector elements.
                    frmts{ii} = ['[ ' frmts{ii} ']'];               % Surroung by square brackets.
                end
            end
            
            % Construct the final string:
            msg_ = '';
            for ii=1:length(frmts)
                msg_ = [msg_ msg_split{ii} frmts{ii}]; %#ok<*AGROW>
            end
            msg_ = [msg_ msg_split{end}];
            
            % Print!
            msgStr = FunPrint.sprintf_cell(msg_, varargin);
            fprintf(msgStr); 
        end

        function msgStr = sprintf_cell(msg, vars)
        % sprintf with variable number of input arguments.
            
            % Sanity check:
            narginchk(1, 2);
            if nargin == 1, vars = []; end
            
            switch length(vars)
                case 0
                    msgStr = sprintf(msg);
                case 1
                    msgStr = sprintf(msg, vars{1});
                case 2
                    msgStr = sprintf(msg, vars{1}, vars{2});
                case 3
                    msgStr = sprintf(msg, vars{1}, vars{2}, vars{3});
                case 4
                    msgStr = sprintf(msg, vars{1}, vars{2}, vars{3}, vars{4});
                case 5
                    msgStr = sprintf(msg, vars{1}, vars{2}, vars{3}, vars{4}, vars{5});
                case 6
                    msgStr = sprintf(msg, vars{1}, vars{2}, vars{3}, vars{4}, vars{5}, vars{6});
                case 7
                    msgStr = sprintf(msg, vars{1}, vars{2}, vars{3}, vars{4}, vars{5}, vars{6}, vars{7});
                case 8
                    msgStr = sprintf(msg, vars{1}, vars{2}, vars{3}, vars{4}, vars{5}, vars{6}, vars{7}, vars{8});
                case 9
                    msgStr = sprintf(msg, vars{1}, vars{2}, vars{3}, vars{4}, vars{5}, vars{6}, vars{7}, vars{8}, vars{9});
                case 10
                    msgStr = sprintf(msg, vars{1}, vars{2}, vars{3}, vars{4}, vars{5}, vars{6}, vars{7}, vars{8}, vars{9}, vars{10});
            end
        end
    end
end