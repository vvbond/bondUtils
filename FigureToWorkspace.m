classdef FigureToWorkspace < handle
    properties
        hFig
        hBtn
        nameXData = 't'
        nameYData = 'x'
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
            if isempty(hax.Children), return; end
            
            prompt = {'XData name', 'YData name'};
            definput = {ftws.nameXData, ftws.nameYData};
            answer = inputdlg(prompt, 'Save to workspace', 1, definput);
            if isempty(answer), return; end
            
            ftws.nameXData = answer{1};
            ftws.nameYData = answer{2};
            % Save:
            assignin('base', ftws.nameXData, hax.Children(1).XData);
            assignin('base', ftws.nameYData, hax.Children(1).YData);
        end
    end
end