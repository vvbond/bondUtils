classdef WTP < handle
% "What's the point?" (WTP) is an interactive tool for figure navigation. 
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
        infotext
        panOn
        panOldAxis
        panFigPoint
        panScaling
        zoomSpeed
    end
    methods
        %% Constructor
        function tp = WTP(hfig)
            % Parse input:
            if nargin == 0
                hfig = gcf;
            end
            % Defaults:
            tp.hfig = hfig;
            tp.hax = gca;
            tp.displayOn = 1;
            tp.panMode = 1;
            tp.zoomMode = 1;
            tp.zoomSpeed = .1;
            pos = get(gca,'CurrentPoint');
            tp.p = pos(1,[1 2]); % cursor position.
            tp.padding = [10 -15];
            tp.fontSize = 12;
            tp.format = {'% 10.2f'};
            tp.color = 'w';
            tp.infotext = text(tp.p(1),... 
                               tp.p(2),... 
                               { num2str(tp.p(1), tp.format{1}), num2str(tp.p(2), tp.format{end}) },...
                               'FontSize', tp.fontSize,...
                               'Color', tp.color);
            tp.bmfun = {};
            tp.bdfun = {};
            tp.bufun = {};
            % Interaction callbacks:
            set(tp.hfig,'WindowButtonMotionFcn',@(src,evt) wbmcb(tp,src,evt));
            set(tp.hfig,'WindowButtonUpFcn',    @(src,evt) wbucb(tp,src,evt));
            set(tp.hax, 'ButtonDownFcn', @(src,evt) axbdcb(tp,src,evt));
            set(tp.hfig, 'WindowScrollWheelFcn',  @(src,evt) wswcb(tp,src,evt));
            
            
            % Disable hittest for images covering the whole axes:
            set(findall(gcf,'type','image'), 'HitTest', 'off');
        end
    end
    methods(Hidden = true, Access = private)
        %% Window button motion callback
        function wbmcb(tp,src,evt)
            % Get the cursor position:
            pos = get(gca,'CurrentPoint');
            tp.p = pos(1,[1 2]); % cursor position.
            
            % Display the cursor position sideways of the cursor:
            if tp.displayOn
                set(tp.infotext, 'Position', [tp.p 0],... 
                                 'String', { num2str(tp.p(1), tp.format{1}), num2str(tp.p(2), tp.format{end}) },...
                                 'Color', tp.color,...
                                 'Units', 'data',...
                                 'HitTest', 'off');
                % Adjust position for padding:
                tp.infotext.Units = 'pixels';
                tp.infotext.Position = tp.infotext.Position + [tp.padding 0];
                tp.infotext.Units = 'data';
            end
            
            % Check if the axis pan is intended:
            if tp.panMode == 1
                if tp.panOn
                    oldFigUnits = get(gcf, 'Units');
                    set(gcf, 'units', 'pixels');
                    panDxDy = (get(gcf,'currentPoint') - tp.panFigPoint).*tp.panScaling;
                    set(gcf, 'units', oldFigUnits);
                    xdir = -2*strcmpi(get(gca,'XDir'),'reverse')+1; % xdir = 1 (normal) or -1 (reverse).
                    ydir = -2*strcmpi(get(gca,'YDir'),'reverse')+1;
                    axis(tp.panOldAxis - panDxDy([1 1 2 2]).*[xdir xdir ydir ydir]);
                end
            end
            
            % Execute mouse movement functions:
            for ii=1:length(tp.bmfun)
                tp.bmfun{1}();
            end
        end
        
        %% Window button up callback
        function wbucb(tp,src,evt)
            tp.panOn = 0;
        end
        %% Window button down callback
        function wbdcb(tp,src,evt)
            
        end

        %% Window Mouse scroll wheel callback
        function wswcb(tp,src,evt)
        % Zoom by scroll wheel.
            zfactor = 1 + sign(evt.VerticalScrollCount)*tp.zoomSpeed;
            zoom(zfactor);
        end
        
        %% Axis button down (click) callback
        function axbdcb(tp,src,evt)
            tp.panOn  = 1;
            oldFigUnits = get(gcf, 'Units');
            set(gcf, 'units', 'pixels');
            tp.panFigPoint = get(gcf, 'currentPoint');  % Get current point w.r.t. the current figure.
            set(gcf, 'units', oldFigUnits);
            tp.panOldAxis  = axis;  % Store the initial axis info.
            
            % Find axes dimensions in pixels:
            hax = gca;
            set(hax, 'units', 'pixels');
            axpos = get(hax, 'position');
            set(hax, 'units', 'normalized');
            tp.panScaling = [ diff(xlim)/axpos(3) diff(ylim)/axpos(4) ];     
        end
        
    end
end