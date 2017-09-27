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
    
    %% {Con,De}structor
    methods
        function fpr = FunPrint()
            fpr.backspace = '';
        end
    end
    
    %% Some fun
    methods
        function over(fpr, msg, varargin)
            msgStr = sprintf(msg, varargin{:});
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
            msgStr = sprintf(msg_, varargin{:});
            fprintf(msgStr); 
        end
    end
end