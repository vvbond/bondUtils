function newf(funame, inarg, outarg)
% Automatically create a documentation for a new function.

templ = {
'------------------------------------------------------',...
'<definition>',...
'% <fundesc>',... 
'%',... 
'<usage>',...
'%',...
'% INPUT:',...
'% <inarglist>',...
'%',...
'% OUTPUT:',...
'% <outarglist>',...
'%',...
'% Examples:',...
'%  <funame>(<inarg>);',...
'%  [<outarg>]=<funame>(<inarg>);',...
'%',...
'% See also: <other funame>.',...
' ',...
'<date>',...
'%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876'...
};

% Prompt for function parameters if not specified:
switch nargin
    case 0
        funame = input('Function name: ', 's');
        inarg = input('Input arguments: ', 's');
        outarg = input('Output arguments: ', 's');
    case 1
        inarg = input('Input arguments: ', 's');
        outarg = input('Output arguments: ', 's');
    case 2
        inarg = inarg{1};
        outarg = input('Output arguments: ', 's');
    case 3
        inarg = inarg{1};
        outarg = outarg{1};
    otherwise
        error('Wrong number of input arguments.');
end

% Prompt for the function description:
fundesc = input('Describe the function: ', 's');

% Split the lists of arguments and prompt for description:
inargs = [];
outargs = [];
inargdesc = [];
outargdesc = [];
if ~isempty(inarg)  
    inargs  = strsplit(strrep(inarg,' ',''), ','); 
    for ii=1:length(inargs)
        inargdesc{ii} = input(['Describe ' inargs{ii} ': '],'s');
    end
end
if ~isempty(outarg) 
    outargs = strsplit(strrep(outarg,' ',''), ','); 
    for ii=1:length(outargs)
        outargdesc{ii} = input(['Describe ' outargs{ii} ': '],'s');
    end
end

% Save the user format preferences:
userFormat = get(0,'FormatSpacing');
format compact

for ii=1:length(templ)
    l = templ{ii};
    key = regexpi(l,'<\w*>', 'match');
    if isempty(key)
        disp(l);
    else
        switch key{1}
            case '<inarglist>'
                arglist(inargs, inargdesc);
            case '<outarglist>'
                arglist(outargs, outargdesc);
            case '<definition>'
                fundef(funame, inargs, outargs);
            case '<usage>'
                funusage(funame, inargs, outargs);
            otherwise
                insertkey(l,key);
        end
    end
end

% Restore user format preferences:
set(0,'FormatSpacing',userFormat);

%% Functions:
    function fundef(funame, inargs, outargs)
        if isempty(inargs)
            inargstr = '';
        else
            inargstr = strjoin(inargs, ', ');
        end
        if isempty(outargs)
            disp(['function ' funame '(' inargstr ')']);
        else
            if length(outargs) == 1
                disp(['function ' outargs{1} ' = ' funame '(' inargstr ')']);
            else
                outargstr = ['[' strjoin(outargs,', ') ']'];
                disp(['function ' outargstr ' = ' funame '(' inargstr ')']);
            end
        end
    end

    function funusage(funame, inargs, outargs)
        if isempty(inargs)
            inargstr = '';
        else
            inargstr = strjoin(inargs, ', ');
        end
            
        if isempty(outargs)
            disp(['% Usage: ' funame '(' inargstr ')']);
        else
            if length(outargs) == 1
                disp(['% Usage: ' outargs{1} ' = ' funame '(' inargstr ')']);
            else
                outargstr = ['[' strjoin(outargs,', ') ']'];
                disp(['% Usage: ' outargstr ' = ' funame '(' inargstr ')']);
            end
        end
    end
    
    function insertkey(l,key)
        for jj=1:length(key)
            k = key{jj};
            switch k
                case '<funame>'
                    krep = funame;
                case '<inarg>'
                    krep = inarg;
                case '<outarg>'
                    krep = outarg;
                case '<date>'
                    krep = ['%% Created: ' datestr(now)];
                case '<fundesc>'
                    krep = [fundesc '.'];
            end
            l = strrep(l,k,krep);
        end
        disp(l);
    end

    function arglist(args, argdesc)
    % Insert descriptions of the arguments list.

        % If no arguments provided, exit:
        if isempty(args) 
            disp('%  None.');
            return; 
        end
        % Insert description:
        for jj=1:length(args)
           disp(['% ' args{jj} ' - ' argdesc{jj} '.']); 
        end
    end

end