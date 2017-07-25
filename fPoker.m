classdef fPoker < handle
% Interactive tool to poke around in a figure.
% 
% The tool facilitates live pointer display, scroll-wheel zooming and drag-like axes panning.

    properties
        p           % 1-by-2 vector of pointer x and y coordinates.
        pix         % for images only, 1-by-2 vector of pointer x and y indices.
        hfig        % asociated figure handle.
        hax         % handle to the current axes.
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
    
    % Image-related properties:
    properties(Hidden = true)
        xplot
        yplot
        himg        % handle to the image in the figure.
        p0          % coordinates of the image origin.
        dx          % increment on the x-axis.
        dy          % increment on the y-axis.
        hXfig       % handle of the X-monitor figure.
        hYfig       % handle of the Y-monitor figure.
        hXplot      % handles for the x/y line plots.
        hYplot
        hXplot_Y    % handles for position markers in the X/Y moninitor.
        hYplot_X
        hXMonitorTitle
        hYMonitorTitle
        xMonitorOnOff = 0;  % X/Y monitor switches.
        yMonitorOnOff = 0;
        xMonitorRunning = 0;
        yMonitorRunning = 0;
    end
        
    % Auxiliary properties:
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
    
    properties(Access = private)
        OnOff = 0      % boolean indicating tool's on/off state.
    end
    
    methods
        %% Constructor
        function fp = fPoker(hfig)
        
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
            if isempty(findobj(ht, 'Tag', 'pkrBtn'))
                PokerIcon = load(fullfile(fileparts(mfilename('fullpath')),'/icons/fPoker1.mat'));
                fp.hBtn = uitoggletool(ht(1), 'OnCallback',  @(src,evt) PokerON(fp,src,evt),...
                                    'OffCallback', @(src,evt) PokerOFF(fp,src,evt),...
                                    'CData', PokerIcon.cdata, ...
                                    'TooltipString', 'Figure "Poker" tool', ...
                                    'Tag', 'pkrBtn',... 
                                    'Separator', 'on');
            end
            
           % If axes has an image, grab its handle:
           fp.himg = findobj(fp.hax, 'type', 'image');
           
           %  Get scaling info about the image:
           if ~isempty(fp.himg) && ishandle(fp.himg)
               fp.init();
                               
               % Prepare handles for the X/Y line plots:
               fp.hXfig = randi(1e6);
               fp.hYfig = randi(1e6);
           else
               fp.color = 'k';
           end
        end
        
        function init(fp)
        % Initialize scaling coefficients.
        
           fp.p0 = [fp.himg.XData(1) fp.himg.YData(1)];

           [nRows, nCols] = size(fp.himg.CData);
           if length(fp.himg.XData) == nCols
               fp.dx = diff(fp.himg.XData(1:2));
           else
               warning('The length of the X-coordinate vector doesn''t match the number of columns in the image.');
               fp.dx = diff(fp.himg.XData([1,end]) )/( nCols - 1 );
           end

           if length(fp.himg.YData) == nRows
               fp.dy = diff(fp.himg.YData(1:2));
           else
               warning('The length of the Y-coordinate vector doesn''t match the number of rows in the image.');
               fp.dy = diff(fp.himg.XData([1,end]))/( nRows - 1 );
           end
        end
        
        %% Destructor
        function delete(fp)
            
            if ishandle(fp.hBtn)
                delete(fp.hBtn);
            end
        end
        
        %% ON switch
        function PokerON(fp, src, evt)
        % Enable the Poker tool.
        
            % Turn off other interactive tools:
            pan off, zoom off, plotedit off, datacursormode off
            
            fp.hax = gca;
            
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
            
            % Re-initialize the X- and Y-monitor figures:
            if ishandle(fp.himg)
                fp.hXfig = randi(1e6);
                fp.hYfig = randi(1e6);
                fp.hXplot = -1;
                fp.hYplot = -1;
            end
            
            % Update the state:
            fp.OnOff = 1;
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
            
            % Update the state:
            fp.OnOff = 0;
        end
        
        %% X/Y monitor switch
        function monitor(fp, dim)
        % Toggle the x- or y- monitor.
        %
        % dim - string: 'x' or 'y'.
            switch dim
                case 'x'
                    fp.xMonitorOnOff = mod(fp.xMonitorOnOff + 1, 2); % flip the switch.
                    
                    % Report the status:
                    if fp.xMonitorOnOff
                        disp('X-Monitor enabled: click to activate/deactivate.');
                    else
                        disp('X-Monitor disabled.');
                    end
                    
                case 'y'
                    fp.yMonitorOnOff = mod(fp.yMonitorOnOff + 1, 2); % flip the switch.
                    
                    % Report the status:
                    if fp.yMonitorOnOff
                        disp('Y-Monitor enabled: click to activate/deactivate.');
                    else
                        disp('Y-Monitor disabled.');
                    end
            end
        end
        
        %% X/Y line plots
        function xmonitor(fp)
            if isempty(fp.hXplot) || ~ishandle(fp.hXplot)
                fp.xplot = [fp.himg.YData(:), fp.himg.CData(:,fp.pix(1))];
                yLabel = get(fp.hax, 'YLabel');
                
                figure(fp.hXfig); clf;
                set(fp.hXfig, 'NumberTitle', 'off', 'Name', 'X-Monitor');
                fp.hXplot = plot(fp.xplot(:,1), fp.xplot(:,2)); 
                
                % Vertical line indicating the cursor position:
%                 hold on;
%                 fp.hXplot_Y = plot([1 1]*fp.p(2), ylim, '--');
%                 hold off;
                fp.hXMonitorTitle = title(sprintf('x = %1.2f;  ix = %1d', fp.p(1), fp.pix(1)));
                xlabel(yLabel.String);
                box on; grid on;
                pan xon; zoom xon
                
                if exist('Rulerz', 'file') == 2
                    Rulerz('x');
                end

                
                % Return focus to the main figure:
                figure(fp.hfig);
            else
                fp.xplot = [fp.himg.YData(:), fp.himg.CData(:,fp.pix(1))];
                set(fp.hXplot, 'xdata', fp.xplot(:,1), 'ydata', fp.xplot(:,2) );
%                 set(fp.hXplot_Y, 'xdata', [1 1]*fp.p(2), 'ydata', arange(fp.himg.CData(:,fp.pix(1))));
                set(fp.hXMonitorTitle, 'String', sprintf('x = %1.2f;  ix = %1d', fp.p(1), fp.pix(1)));
            end
        end
        
        function ymonitor(fp)
            if isempty(fp.hYplot) || ~ishandle(fp.hYplot)
                fp.yplot = [fp.himg.XData(:), fp.himg.CData(fp.pix(2), :)'];
                yLabel = get(fp.hax, 'XLabel');
                
                figure(fp.hYfig); clf;
                T = [ 1 0 0 0
                      0 1 0 0
                      0 0 1 0
                      0 1 0 1 ];
                fpos = fp.hfig.Position*T; % shift (translate).
                
                set(fp.hYfig, 'NumberTitle', 'off', 'Name', 'Y-Monitor', 'Position', fpos);
                fp.hYplot = plot(fp.yplot(:,1), fp.yplot(:,2)); 
%                 hold on;
%                 fp.hYplot_X = plot([1 1]*fp.p(2), ylim, '--');
%                 hold off;
                fp.hYMonitorTitle = title(sprintf('y = %1.2f;  ix = %1d', fp.p(2), fp.pix(2)));
                xlabel(yLabel.String);
                box on; grid on;
                
                if exist('Rulerz', 'file') == 2
                    Rulerz('x');
                end
                
                % Return focus to the main figure:
                figure(fp.hfig);
            else
                fp.yplot = [fp.himg.XData(:), fp.himg.CData(fp.pix(2), :)'];
                set(fp.hYplot, 'xdata', fp.yplot(:,1), 'ydata', fp.yplot(:,2));
%                 set(fp.hYplot_X, 'xdata', [1 1]*fp.p(2), 'ydata', arange(fp.himg.CData(:,fp.pix(1))));
                set(fp.hYMonitorTitle, 'String', sprintf('y = %1.2f;  ix = %1d', fp.p(2), fp.pix(2)));
            end
        end
    end
    methods(Hidden = true, Access = private)
        %% Window button motion callback
        function wbmcb(fp,src,evt)
            % Get the cursor position:
            pos = get(fp.hax,'CurrentPoint');
            fp.p = pos(1,[1 2]); % cursor position.
            
            cursorString = { num2str(fp.p(1), fp.format{1}), num2str(fp.p(2), fp.format{end}) };
            
            % Find corresponding indices into the image matrix:
            if ishandle(fp.himg)
                fp.init();
                fp.pix = round((fp.p-fp.p0)./[fp.dx, fp.dy])+1;
                % Clip to the image range:
                fp.pix(fp.pix <= 0) = 1;
                [m n] = size(fp.himg.CData);
                if fp.pix(1) > n, fp.pix(1) = n; end
                if fp.pix(2) > m, fp.pix(1) = m; end
                
                cursorString = { sprintf([fp.format{1} ' (%3d)'], fp.p(1), fp.pix(1))
                                 sprintf([fp.format{end} ' (%3d)'], fp.p(2), fp.pix(2)) };
                    
            end
            
            % Display the cursor position sideways of the cursor:
            if fp.displayOn
                set(fp.infotext, 'Position', [fp.p 0],... 
                                 'String', cursorString,...
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
            
            % X/Y monitor:            
            if fp.xMonitorOnOff && fp.xMonitorRunning
                fp.xmonitor();
            end
            
            if fp.yMonitorOnOff && fp.yMonitorRunning
                fp.ymonitor();
            end
            
            % Execute mouse movement functions:
            for ii=1:length(fp.bmfun)
                fp.bmfun{ii}(fp);
            end
        end
        
        %% Window button up callback
        function wbucb(fp,src,evt)

            switch src.SelectionType
                case 'normal'     % single click.
                    fp.panOn = 0;

                    if fp.xMonitorOnOff
                        fp.xMonitorRunning  = mod(fp.xMonitorRunning + 1, 2); % flip the switch.
                    end

                    if fp.yMonitorOnOff
                        fp.yMonitorRunning  = mod(fp.yMonitorRunning + 1, 2); % flip the switch.
                    end
                    
                    % Execute user-defined button up functions:
                    for ii=1:length(fp.bufun)
                        fp.bufun{ii}(fp);
                    end
                case 'open'     % double click.
                    axis tight
                    fp.panOn = 0;
            end
                
            
        end
        
        %% Window button down callback
        function wbdcb(fp,src,evt)
            
        end

        %% Window Mouse scroll wheel callback
        function wswcb(fp,src,evt)
        % Zoom by scroll wheel.
        
            % Store current cursor position:
            cpos = get(gca,'currentPoint'); xy0 = cpos(1,1:2);
            
            % Zoom:
            zfactor = 1 + sign(evt.VerticalScrollCount)*fp.zoomSpeed;
            zoom(zfactor);
            
            % Adjust x and y lims to restore the cursor position:
            cpos = get(gca,'currentPoint'); xy1 = cpos(1,1:2);
            delta = xy1 - xy0;
            axis(axis - delta*blkdiag([1 1], [1 1]));
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