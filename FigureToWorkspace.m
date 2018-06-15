classdef FigureToWorkspace < handle
    properties
        hFig
        hBtn
        nameVar   = 'A'
        nameXData = 'x'
        nameYData = 'y'
    end
    methods
        %% Constructor
        function ftws = FigureToWorkspace(hfig)
            
            % Parse input:
            if nargin == 0
                ftws.hFig = gcf;
            elseif nargin == 1
                ftws.hFig = hfig;
            end
            
            % Add a pushbutton to the toolbar:
            ht = findall(ftws.hFig,'Type','uitoolbar');
            saveIcon = load(fullfile(fileparts(mfilename('fullpath')),'/icons/saveIcon.mat'));
            ftws.hBtn = uipushtool(ht(1), 'CData', saveIcon.cdata, ...
                                          'ClickedCallback', @(src, evt) ftws.save_to_workspace(src, evt),...
                                          'TooltipString', 'Save to workspace', ...
                                          'Tag', 'FigToWS ',... 
                                          'Separator', 'on');

        end
        
        %% Main
        function save_to_workspace(ftws, ~, ~)
            hax = gca;
            % Find line plots:
            hl = findall(hax, 'Type', 'Line');
            if ~isempty(hl)
                hl = hl(end:-1:1);
                numLines = length(hl);
                titleStr = sprintf('Save %d lines data', numLines);
                prompt = {'Variable name: ', 'XData name: ', 'YData name: '};
                definput = {ftws.nameVar, ftws.nameXData, ftws.nameYData};
                answer = inputdlg(prompt, titleStr, 1, definput);
                if isempty(answer), return; end
            
                ftws.nameVar   = answer{1};
                ftws.nameXData = answer{2};
                ftws.nameYData = answer{3};
                
                S = struct(ftws.nameXData, [], ftws.nameYData, []);
                for ii=1:numLines
                    S(ii).(ftws.nameXData) = hl(ii).XData(:);
                    S(ii).(ftws.nameYData) = hl(ii).YData(:);
                end
                
                % Save:
                assignin('base', ftws.nameVar, S);
            end
        end
    end
end