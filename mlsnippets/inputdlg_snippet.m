function inputdlg_snippet()
% Outputs an input dialog template..
%
% Usage: inputdlg_snippet()
%
% INPUT:
%  None.
%
% OUTPUT:
%  None.
%
% Examples:
%  inputdlg_snippet();
%
% See also: <other funame>.
 
%% Created: 13-Jan-2015 18:12:04
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

template = {
'% ---- Incert an input dialog ----',...
'prompt = {''''};',...
'def = {};',...
'numLines = 1;',...
'dlgTitle = '''';',...
'ansr = inputdlg(prompt, dlgTitle, numLines, def);',...
' ',...
'if isempty(ansr)',...
'    % do nothing.',...
'    return;',...
'else',...
'    % do something.',...
'end' ...
};

for ii=1:length(template)
    disp(template{ii});
end
