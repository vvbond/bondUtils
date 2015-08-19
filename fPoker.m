classdef fPoker < handle
% Poker is an interactive tool for "poking" in a figure. 
% 
% WTP facilitates live pointer display, scroll-wheel zooming and drag-like axes panning.

    properties
        p           % 1-by-2 vector of pointer x and y coordinates.
        hfig        % asociated figure handle.
        hax         % handle to the current figure
        format      % text format.
        color       % text color.
        padding     % 1-by-2 vector of padding along x and y coordinates, [px].
        fontSize    % text size.
        displayOn   % binary switch: 0 - not display the cursor position, 1 (default) - display cursor position.
        panMode     % binary switch for click&drag panning: 0 - pan is off, 1 (default) - on. 
        zoomMode    % binary switch for zooming by scroll wheel: 0 - off, 1 (default) - on. 
        bmfun       % cell array of function handles, to be executed at the button (mouse) motion event.
        bdfun       % cell array of function handles, to be executed at the buttond down (i.e., click) event.
        bufun       % cell array of function handles, to be executed at the buttond up event.
    end
    properties(Hidden = true)
        hBtn        % handle to the switch button.
        infotext
        panOn
        panOldAxis
        panFigPoint
        panScaling
        zoomSpeed
        oldWindowButtonMotionFcn
        oldWindowButtunUpFcn
        oldWindowScrollWheelFcn
        oldAxesButtonDownFcn
    end
    methods
        %% Constructor
        function fp = fPoker(hfig)
        % Constructor of an fPoker object.
        
            % Parse input:
            if nargin == 0
                hfig = gcf;
            end
            
            % Defaults:
            fp.hfig = hfig;
            fp.hax = gca;
            fp.displayOn = 1;
            fp.panMode = 1;
            fp.zoomMode = 1;
            fp.zoomSpeed = .1;
            pos = get(gca,'CurrentPoint');
            fp.p = pos(1,[1 2]); % cursor position.
            fp.padding = [10 -15];
            fp.fontSize = 12;
            fp.format = {'% 10.2f'};
            fp.color = 'w';
            fp.bmfun = {};
            fp.bdfun = {};
            fp.bufun = {};
            
            % Toggle button:
            ht = findall(fp.hfig,'Type','uitoolbar');
            PokerIcon = load(fullfile(fileparts(mfilename('fullpath')),'/icons/fPoker1.mat'));
            uitoggletool(ht(1), 'OnCallback',  @(src,evt) PokerON(fp,src,evt),...
                                'OffCallback', @(src,evt) PokerOFF(fp,src,evt),...
                                'CData', PokerIcon.cdata, ...
                                'TooltipString', 'Figure "Poker" tool', ...
                                'Tag', 'pkrBtn',... 
                                'Separator', 'on');            
        end
        
        %% ON switch
        function PokerON(fp, src, evt)
        % Enable the Poker tool.
            
            % Store existing interaction callbacks:
            fp.oldWindowButtonMotionFcn = get(fp.hfig,'WindowButtonMotionFcn');
            fp.oldWindowButtunUpFcn     = get(fp.hfig,'WindowButtonUpFcn');
            fp.oldAxesButtonDownFcn = get(fp.hax, 'ButtonDownFcn');
            fp.oldWindowScrollWheelFcn = get(fp.hfig, 'WindowScrollWheelFcn');

            set(fp.hfig,'WindowButtonMotionFcn',@(src,evt) wbmcb(fp,src,evt));
            set(fp.hfig,'WindowButtonUpFcn',    @(src,evt) wbucb(fp,src,evt));
            set(fp.hax, 'ButtonDownFcn', @(src,evt) axbdcb(fp,src,evt));
            set(fp.hfig, 'WindowScrollWheelFcn',  @(src,evt) wswcb(fp,src,evt));
            
            % Disable hittest for images covering the whole axes:
            set(findall(gcf,'type','image'), 'HitTest', 'off');

            % Initialize info display:
            fp.infotext = text(fp.p(1),... 
                               fp.p(2),... 
                               { num2str(fp.p(1), fp.format{1}), num2str(fp.p(2), fp.format{end}) },...
                               'FontSize', fp.fontSize,...
                               'Color', fp.color);                           
        end
        
        %% OFF switch
        function PokerOFF(fp, src, evt)
        % Disable the Poker tool.
            
            % Restore existing interaction callbacks:
            set(fp.hfig, 'WindowButtonMotionFcn', fp.oldWindowButtonMotionFcn);
            set(fp.hfig, 'WindowButtonUpFcn',     fp.oldWindowButtunUpFcn);
            set(fp.hax,  'ButtonDownFcn',         fp.oldAxesButtonDownFcn);
            set(fp.hfig, 'WindowScrollWheelFcn',  fp.oldWindowScrollWheelFcn);
            
            % Delete the info text:
            set(fp.infotext, 'String', '');
            
            % Enable hittest for images covering the whole axes:
            set(findall(gcf,'type','image'), 'HitTest', 'on');

        end
    end
    methods(Hidden = true, Access = private)
        %% Window button motion callback
        function wbmcb(fp,src,evt)
            % Get the cursor position:
            pos = get(gca,'CurrentPoint');
            fp.p = pos(1,[1 2]); % cursor position.
            
            % Display the cursor position sideways of the cursor:
            if fp.displayOn
                set(fp.infotext, 'Position', [fp.p 0],... 
                                 'String', { num2str(fp.p(1), fp.format{1}), num2str(fp.p(2), fp.format{end}) },...
                                 'Color', fp.color,...
                                 'Units', 'data',...
                                 'HitTest', 'off');
                % Adjust position for padding:
                fp.infotext.Units = 'pixels';
                fp.infotext.Position = fp.infotext.Position + [fp.padding 0];
                fp.infotext.Units = 'data';
            end
            
            % Check if the axis pan is intended:
            if fp.panMode == 1
                if fp.panOn
                    oldFigUnits = get(gcf, 'Units');
                    set(gcf, 'units', 'pixels');
                    panDxDy = (get(gcf,'currentPoint') - fp.panFigPoint).*fp.panScaling;
                    set(gcf, 'units', oldFigUnits);
                    xdir = -2*strcmpi(get(gca,'XDir'),'reverse')+1; % xdir = 1 (normal) or -1 (reverse).
                    ydir = -2*strcmpi(get(gca,'YDir'),'reverse')+1;
                    axis(fp.panOldAxis - panDxDy([1 1 2 2]).*[xdir xdir ydir ydir]);
                end
            end
            
            % Execute mouse movement functions:
            for ii=1:length(fp.bmfun)
                fp.bmfun{ii}(fp);
            end
        end
        
        %% Window button up callback
        function wbucb(fp,src,evt)
            fp.panOn = 0;
            % Execute button up functions:
            for ii=1:length(fp.bufun)
                fp.bufun{ii}(fp);
            end

        end
        %% Window button down callback
        function wbdcb(fp,src,evt)
            
        end

        %% Window Mouse scroll wheel callback
        function wswcb(fp,src,evt)
        % Zoom by scroll wheel.
            y0 = [1 0]*get(gca,'currentPoint')*[0;1;0];
            zfactor = 1 + sign(evt.VerticalScrollCount)*fp.zoomSpeed;
            zoom(zfactor);
            % Adjuts ylims to center the axes on the cursor point:
            y1 = [1 0]*get(gca,'currentPoint')*[0;1;0];
            ylims = ylim;
            dy = y1 - y0;
            ylim(ylims - dy);
        end
        
        %% Axis button down (click) callback
        function axbdcb(fp,src,evt)
            fp.panOn  = 1;
            oldFigUnits = get(gcf, 'Units');
            set(gcf, 'units', 'pixels');
            fp.panFigPoint = get(gcf, 'currentPoint');  % Get current point w.r.t. the current figure.
            set(gcf, 'units', oldFigUnits);
            fp.panOldAxis  = axis;  % Store the initial axis info.
            
            % Find axes dimensions in pixels:
            hax = gca;
            set(hax, 'units', 'pixels');
            axpos = get(hax, 'position');
            set(hax, 'units', 'normalized');
            fp.panScaling = [ diff(xlim)/axpos(3) diff(ylim)/axpos(4) ];     
        end
        
    end
end