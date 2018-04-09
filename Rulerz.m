classdef Rulerz < handle
%% Interactive tool for measuring distances along x- and/or y-axes.
    properties(SetObservable)
        xx      % 2-vector of x-coordinates for the two vertical lines.
        yy      % 2-vector of y-coordinates for the two horizontal lines. 
    end
    properties
        axis    % 1 or 'x' for x-lines only;
                % 2 or 'y' for y-lines only;
                % otherwise - both x- and y-lines are displayed.
        lColor  % lines color.
        lStyle  % lines style.
        lWidth  % lines width.
        annotationPosition  % position of the annotation box.
        annotationBgColor   % background color of the annotation box.
        bmfun = {};
    end
    
    properties(Hidden = true)
        lineIx      % index of the "clikcked" (selected) line.
        hBtn        % handle of the toggle button.
        hLines      % handles of the ruler lines.
        hInfoBox    % handle of the annotation text box.
        oldButtonMotionFcn
        oldButtonUpFcn
    end
    
    events
        axisChange
    end
    
    methods
        %% Constructor
        function rlz = Rulerz(raxis)
            
            % Parse input:
            if nargin == 0
                raxis = 3;
            end
            
            rlz.axis = raxis;
            % Add a toolbar toggle button:
            ht = findall(gcf,'Type','uitoolbar');
            switch raxis
                case {1, 'x'}
                    rlzIcon = load(fullfile(fileparts(mfilename('fullpath')),'/icons/RulerzX.mat'));
                case {2, 'y'}
                    rlzIcon = load(fullfile(fileparts(mfilename('fullpath')),'/icons/RulerzY.mat'));
                otherwise
                    rlzIcon = load(fullfile(fileparts(mfilename('fullpath')),'/icons/Rulerz.mat'));
            end

            rlz.hBtn = uitoggletool(ht(1), 'OnCallback', @(src,evt) RulerzON(rlz,src,evt),...
                                        'OffCallback',@(src,evt) RulerzOFF(rlz,src,evt),...
                                        'CData', rlzIcon.cdata, ...
                                        'TooltipString', 'X-/Y- rulers', ...
                                        'Tag', 'rulerz ',... 
                                        'Separator', 'on');
            rlz.lColor = [.5 .5 .5];
            rlz.lStyle = '--';
            rlz.lWidth = 2;
            rlz.annotationBgColor = [.95 .95 .95];
            rlz.annotationPosition = [0 .9 .1 .1];

            % Add listener:
            addlistener(rlz, 'axisChange', @(src, evt) axisChangeEvt(rlz,src,evt));
        end
        
        %% Destructor
        function delete(rlz)
            if ishandle(rlz.hBtn)
                set(rlz.hBtn, 'State', 'off');
                delete(rlz.hBtn);
            end
        end
    end
    
%% Setter methods
    methods 
        function set.axis(rlz, val)
        % Monitor the axis change and set the appropriate icon to the toolbar.
            rlz.axis = val;
            notify(rlz, 'axisChange');
        end
    end
%% Hidden methods handling user interactions
    methods(Hidden = true) 
        %% Rulerz ON:
        function RulerzON(rlz, ~, ~)
        % Display ruler lines.
            
            % Define x- and y- coordinates of the ruler lines:            
            xlims = get(gca,'xlim')';
            ylims = get(gca,'ylim')';

            dx = diff(xlims);
            dy = diff(ylims);
            if isempty(rlz.xx)
                rlz.xx = xlims(1)+[1 2]./3*dx;
            end
            if isempty(rlz.yy)
                rlz.yy = ylims(1)+[1 2]./3*dy; % lines position [x1 x2 y1 y2].
            end
            
            % Plot lines:
            hold on;
            switch rlz.axis
                case {1, 'x'}
                    rlz.hLines = plot([1;1]*rlz.xx, ylims, rlz.lStyle, 'LineWidth', rlz.lWidth, 'Color', rlz.lColor, 'Tag', 'rulersLine');
                case {2, 'y'}
                    rlz.hLines = plot(xlims, [1;1]*rlz.yy, rlz.lStyle, 'LineWidth', rlz.lWidth, 'Color', rlz.lColor, 'Tag', 'rulersLine');
                otherwise 
                    rlz.hLines = [ plot([1;1]*rlz.xx, ylims, rlz.lStyle, 'LineWidth', rlz.lWidth, 'Color', rlz.lColor, 'Tag', 'rulersLine')
                                   plot(xlims, [1;1]*rlz.yy, rlz.lStyle, 'LineWidth', rlz.lWidth, 'Color', rlz.lColor, 'Tag', 'rulersLine') ];
            end
            xlim(xlims);
            ylim(ylims);
            
            % Annotation box:
            rlz.hInfoBox = annotation('textbox', rlz.annotationPosition, ...
                                      'FontName', 'Courier',...
                                      'string', rlz.infoString(),... 
                                      'Color', 'k', 'BackgroundColor', rlz.annotationBgColor, 'EdgeColor', 'k', ...
                                      'Tag', 'rulersInfo');            
            
            % Set lines interaction callback:
            zoom off, pan off, datacursormode off
            set(rlz.hLines, 'ButtonDownFcn', @(src,evt) lbdcb(rlz, src, evt));
        end
        
        %% Rulerz OFF:
        function RulerzOFF(~, ~, ~)
            delete(findall(gcf, 'tag', 'rulersLine'));
            delete(findall(gcf, 'tag', 'rulersInfo'));
        end
        
        %% Interaction callbacks:
        function lbdcb(rlz, src, ~)
        % Line button down callback.
            
            % Identify the index of the clicked line:
            rlz.lineIx = find(src == rlz.hLines); % line index.
            
            % Store old interaction callbacks:
            rlz.oldButtonMotionFcn = get(gcf, 'WindowButtonMotionFcn');
            rlz.oldButtonUpFcn = get(gcf, 'WindowButtonUpFcn');
            
            % Set new interaction callbacks:
            set(gcf, 'WindowButtonMotionFcn', @(src,evt) wbmcb(rlz, src, evt), ...
                     'WindowButtonUpFcn', @(src, evt) wbucb(rlz, src, evt));
        end

        function wbmcb(rlz, ~, ~)
        % Window button motion callback.
            if rlz.lineIx
                cpos = get(gca, 'CurrentPoint');
                cxpos = cpos(1,1); % cursor x position.
                cypos = cpos(1,2); % cursor x position.
                
                xydata = [ get(rlz.hLines(rlz.lineIx), 'xdata')' get(rlz.hLines(rlz.lineIx), 'ydata')' ]; 
                
                switch find(diff(xydata)==0)
                    case 1
                        rlz.xx(rlz.lineIx) = cxpos;
                        set(rlz.hLines(rlz.lineIx), 'XData', [1 1]*rlz.xx(rlz.lineIx));
                    case 2
                        ix = rlz.lineIx-(rlz.lineIx>2)*2;
                        rlz.yy(ix) = cypos;
                        set(rlz.hLines(rlz.lineIx), 'YData', [1 1]*rlz.yy(ix));
                end
                % Update info box:
                set(rlz.hInfoBox, 'String', rlz.infoString() );
                
                % Execute external mouse movement functions:
                for ii=1:length(rlz.bmfun)
                    rlz.bmfun{ii}(rlz);
                end
            end
        end

        function wbucb(rlz,~,~)
        % Window button up callback.
            rlz.lineIx = 0;
            % Restore the old interaction callbacks:
            set(gcf, 'WindowButtonMotionFcn', rlz.oldButtonMotionFcn,...
                     'WindowButtonUpFcn',     rlz.oldButtonUpFcn);
        end
        
        %% Info string:
        function s = infoString(rlz)
            switch rlz.axis
                case {1, 'x'}
                    s = { ['    x_1    ', '    x_2    ', '    dx    '],...
                           sprintf('%8.2f %8.2f %8.2f', rlz.xx(1), rlz.xx(2), abs(diff(rlz.xx))) };
                case {2, 'y'}
                    s = {  ['    y_1    ', '    y_2    ', '    dy    '],...
                           sprintf('%8.2f %8.2f %8.2f', rlz.yy(1), rlz.yy(2), abs(diff(rlz.yy)))};
                otherwise
                    s = { ['    x_1    ', '    x_2    ', '    dx    '],...
                           sprintf('%8.2f %8.2f %8.2f', rlz.xx(1), rlz.xx(2), abs(diff(rlz.xx))),...
                          ['    y_1    ', '    y_2    ', '    dy    '],...
                           sprintf('%8.2f %8.2f %8.2f', rlz.yy(1), rlz.yy(2), abs(diff(rlz.yy)))};
            end
        end
        
        %% Listener callback for the axisChange event
        function axisChangeEvt(rlz, ~, ~)
    
            % Turn off the current ruler:
            if ishandle(rlz.hBtn)
                set(rlz.hBtn, 'state', 'off');
                % Update the icon:
                switch lower(rlz.axis)
                    case {1, 'x'}
                        rlzIcon = load(fullfile(fileparts(mfilename('fullpath')),'/icons/RulerzX.mat'));
                    case {2, 'y'}
                        rlzIcon = load(fullfile(fileparts(mfilename('fullpath')),'/icons/RulerzY.mat'));
                    otherwise
                        rlzIcon = load(fullfile(fileparts(mfilename('fullpath')),'/icons/Rulerz.mat'));
                end
                set(rlz.hBtn, 'CData', rlzIcon.cdata);
            end
        end
    end    
end