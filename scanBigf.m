function [varargout] = scanbigf(fname,frmt,delimiter,cols)
%% Check input:

%% Configuration:
nSkip = 1;    % Number of header lines to skip.
bSize = 10e6; % Size of a block of characters.
bNum = 1;   % Number of blocks to process. Set to inf for the whole file.

%% Defaults:
a0 = '';
k = 0;
bn = 0; % block number.

%% MAIN PROGRAM:
%% File info:
fid = fopen(fname, 'r');
fInfo = dir(fname);
fSize = fInfo.bytes;
colsFrmt = strsplit(frmt);
nCols = length(colsFrmt);

% Get the number of lines in the text file:
numOfLines = fnumofl(fid);

%% Estimate the space required for variables:
mem = 0;
varL = numOfLines - nSkip; % estimate the length of the variables.
for col = cols
    colf = colsFrmt{col};
    switch colf(1:2)
        case '%u'
            mem = mem + varL*4;
        case '%f'
            mem = mem + varL*8;
        case '%s'
            sw = regexpi(colf,'%s(\d+)', 'tokens'); % string width.
            if ~isempty(sw)
               mem = mem + varL*str2double(sw{1})*2; % 2 bytes per symbol.
            else
               warning('Can''t estimate space for a string variable.');
            end
        otherwise
            error(['Uknown format: ' colf]);
    end
end
% Display memory requirements:
if mem > 2^20
    disp(['Memory required: ' num2str(mem/2^20) ' Mb.']);
else
    disp(['Memory required: ' num2str(mem/2^10) ' Kb.']);
end

%% Preallocate space for the whole file
for jj=1:length(cols)
   col = cols(jj); 
   colf = colsFrmt{col};
   switch colf(1:2)
       case '%u'
           varargout{jj} = zeros(varL,1,'uint32');
       case '%f'
           varargout{jj}=zeros(varL,1);
       case '%s'
           sw = regexpi(colf,'%s(\d+)', 'tokens');
           if ~isempty(sw)
               sw = str2double(sw{1});
               varargout{jj}=char(zeros(varL,sw));
           else
               varargout{jj}=cell(varL,1);
           end
       otherwise
           error(['Uknown format: ' colf]);
   end
end

%% Skip the header:
for ii=1:nSkip
    s = fgetl(fid);
end

%%
while ~feof(fid) && (bn < bNum)
    %% Read a block of characters:
    bn = bn+1;
    disp(' ')
    disp(['Reading in block ' num2str(bn) '.']);
    tic;
    a = [a0 fread(fid, bSize, '*char')']; % read in a block and preappend 
                                          % with a "hanging line" from the 
                                          % previous block. 
                                            
    b = strsplit(a, '\n');                % split block in lines.
    a0 = b{end};  % Store the last "hanging", i.e., probably incomplete, 
                  % line separately.
    fLoaded = ftell(fid)/fSize; % How much file did we loaded?
    if fLoaded < 1   % If not at the end of file,
        b(end) = []; % discard the last "hanging" line of the block.
    end
    bvarL = length(b); % length of the block variables.
    disp([num2str(fLoaded*100) '%'])
    toc;

    %% Parse the block:
    disp('Parsing block.');
    tic;
    for ii = 1:length(b)
%         c = strsplit(strtrim(b{ii}), delimiter, 'CollapseDelimiters', false);
        c = strsplit1(b{ii}, delimiter);
        if length(c) == nCols % Skip empty or header lines in the middle.
            k = k+1;
              % 3. Using varargout instead of eval
              for jj=1:length(cols)
                  col = cols(jj); % the column to extract.
                  switch colsFrmt{col}(1:2)
                      case '%u'
                          varargout{jj}(k) = uint32(str2double(c{col}));
                      case '%f'
                          varargout{jj}(k) = str2double(c{col});
                      case '%s'
                          varargout{jj}(k,:) = c{col};
                  end
              end
        else
            disp(b{ii}) % show failed lines.
        end
    end 
    toc;
end