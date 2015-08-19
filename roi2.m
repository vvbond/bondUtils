classdef roi2 < handle
    % Interactive tool for specifying a 2D region of interest (ROI).
    
    %% 23-Apr-2015
    %% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876
    
    properties
        p           % 2x2 matrix of end points, [p10 p11 p20 p21], of the principle lines.
        xrng        % ROI x range.
        yrng        % ROI y range.
        x2y         % 2-vector of coefficients, [a; b], of the equation y(x) = a*x+b.
        y2x         % 2-vector of coefficients, [c; d], of the equation x(y) = c*y+d.
        lineStyle   % style of the line.
        lineColor   % color of the lines.
        lineWidth   % width of the line.
        mode        % ROI mode: 0 - rectangular, 1 - parallelogram.
    end
    
    properties(Hidden = true)
        % Various handles:
        hfig    % figure handle.
        htbar   % toolbar handle.
        hbtn    % the tool's toolbar button.
        hline   % array of 4 line handles: [top, bottom, left, right].
        
        % Previous state of the figure:
        old_bdcb
        old_bucb
        old_bmcb
        old_fpointer
        old_NextPlot
        axlims
        
        % Interactions:
        clicks      % clicks counter.
        type        % ROI type: 1 -  horizontaly, 2 - verticaly extruded.
        lineIx      % index of the selected line in the hline array.
        old_cpos    % store cursor position for line movement.
        old_p       % store the ROI points matrix, p.
    end
    
    methods
        %% Constructor
        function xyr = roi2(hfig, roimode)
            
            % Parse input:
            if nargin == 0
                xyr.hfig  = gcf;
                xyr.mode = 0;
            elseif nargin == 1 
                xyr.mode = 0;
            else
                xyr.mode = roimode;
            end
            
            % Create toggle button:
            xyr.htbar = findall(gcf,'Type','uitoolbar');
            xyroiIcon = load('roi2Icon.mat');
            xyr.hbtn =  uitoggletool(xyr.htbar(1), 'CData', xyroiIcon.cdata, ...
                                                'onCallback',  @(src,evt) roiOn(xyr,src,evt),...
                                                'offCallback', @(src,evt) roiOff(xyr,src,evt),...
                                                'Separator', 'on',...
                                                'tooltipString', 'ROI' );
            % Defaults:                                
            xyr.clicks = 0;
            xyr.lineStyle = '-';
            xyr.lineColor = [.3 .3 .3];
            xyr.lineWidth = 2;
            xyr.x2y = zeros(2,1);
            xyr.y2x = zeros(2,1);
            xyr.type = 0;
            xyr.axlims = axis;
        end
        
        %% Destructor
        function delete(xyr)
            
            % Delete the tool's button:
            if ishandle(xyr.hbtn), delete(xyr.hbtn); end
        end
        
        %% ROI On/Off callbacks
        function roiOn(xyr,src,evt)
            newroi(xyr);
        end
        
        function roiOff(xyr,src,evt)
            % Delete the previous roi.
            if ishandle(xyr.hline), delete(xyr.hline); end
            xyr.type = 0;
        end
        
        %% Create new ROI
        function xyr = newroi(xyr)
            
            % Disable other interactive tools:
            zoom off, pan off, datacursormode off
            
            % Delete the previous roi:
            if ishandle(xyr.hline)
                delete(xyr.hline);
            end
                        
            % Store previous interaction callbacks:
            xyr.old_bdcb = get(gcf,'WindowButtonDownFcn');
            xyr.old_bmcb = get(gcf,'WindowButtonMotionFcn');
            xyr.old_bucb = get(gcf,'WindowButtonUpFcn');

            % Clear the mouse event handlers:
            set(xyr.hfig,'WindowButtonDownFcn','');
            set(xyr.hfig,'WindowButtonMotionFcn','');
            set(xyr.hfig,'WindowButtonUpFcn','');

            % Store the current hold setting:
            xyr.old_NextPlot = get(gca, 'NextPlot');

            % Change the mouse cursor:
            xyr.old_fpointer = get(gcf,'Pointer');
            set(xyr.hfig,'Pointer','crosshair');

            % Interactions:
            xyr.axlims = axis;
            set(xyr.hfig, 'windowButtonDownFcn', @(src,evt) roi_bdcb(xyr,src,evt));
            hold on;
        end
        
        %% Window button down callback
        function roi_bdcb(xyr,src,evt)
            
            xyr.clicks = xyr.clicks+1;
            
            switch xyr.mode
                case 0
                    roiCreateRectangle(xyr);
                case 1
                    roiCreateParallelogram(xyr);
            end            
        end
        
        %% Window button motion function
        function roi_bmcb(xyr,src,evt)
            
            switch xyr.mode
                case 0
                    roiDrawRectangle(xyr);
                case 1
                    roiDrawParallelogram(xyr);
            end
        end
        
        %% Line button down callback
        function line_bdcb(xyr,src,evt)
            xyr.lineIx = find(src == xyr.hline);
            cpos = get(gca, 'currentPoint');
            xyr.old_cpos = cpos(1,1:2)';
            xyr.old_p = xyr.p;
            
            % Store previous interaction callbacks:
            xyr.old_bdcb = get(gcf,'WindowButtonDownFcn');
            xyr.old_bmcb = get(gcf,'WindowButtonMotionFcn');
            xyr.old_bucb = get(gcf,'WindowButtonUpFcn');
            
            % Set new interaction callbacks:
            set(xyr.hfig, 'windowButtonMotionFcn', @(src,evt) line_bmcb(xyr,src,evt),...
                          'windowButtonUpFcn',     @(src,evt) line_bucb(xyr,src,evt) );

        end
        
        %% Line button motion callback
        function line_bmcb(xyr,src,evt)
            cpos = get(gca, 'currentPoint');
            cpos = cpos(1,1:2)';
            dxdy = cpos - xyr.old_cpos;     % shift vector.
            
            switch xyr.mode
                case 0
                    if xyr.lineIx <= 2 % horizontal lines.
                        shiftV = dxdy.*[0; 1]; % change only the y-coordinate
                        pIx = xyr.lineIx;
                    else % second corner lines.
                        shiftV = dxdy.*[1; 0]; % change only the x-coordinate
                        pIx = xyr.lineIx-2;
                    end
                case 1
                    if xyr.lineIx <=2
                        switch xyr.type
                            case 1
                                pIx = (xyr.lineIx-1)*2 + [1 2]; % point indices, i.e., columns in the xyr.p matrix.
                                shiftV = [1 1; 0 0]*dxdy(1);    % shift vector.
                            case 2
                                pIx = (xyr.lineIx-1)*2 + [1 2]; 
                                shiftV = [0 0; 1 1]*dxdy(2);
                        end
                    else
                        pIx = (xyr.lineIx-3) + [1 3];
                        shiftV = dxdy*[1 1];
                    end
            end
                % New coordinates:
                new_p = xyr.old_p(:,pIx) + shiftV;
                % Check if the ROI exceeds axes limits:
                if all([new_p(1,:)>=xyr.axlims(1), new_p(1,:)<=xyr.axlims(2),...
                        new_p(2,:)>=xyr.axlims(3), new_p(2,:)<=xyr.axlims(4)])
                   xyr.p(:,pIx) = new_p;
                   xyr.update();
                end
        end
        
        %% Line button up callback
        function line_bucb(xyr,src,evt)
            % Restore figure settings:
            set(xyr.hfig, 'windowButtonMotionFcn', xyr.old_bmcb, ...
                          'windowButtonUpFcn',     xyr.old_bucb );
        end
        
        %% Update ROI
        function update(xyr)
            
            % Update plot:
            switch xyr.mode
                case 0
                    set(xyr.hline(1), 'xdata', xyr.p(1,1:2), 'ydata', xyr.p(2,[1 1]));
                    set(xyr.hline(2), 'xdata', xyr.p(1,1:2), 'ydata', xyr.p(2,[2 2]));
                    set(xyr.hline(3), 'xdata', xyr.p(1,[1 1]), 'ydata', xyr.p(2,1:2));
                    set(xyr.hline(4), 'xdata', xyr.p(1,[2 2]), 'ydata', xyr.p(2,1:2));
                case 1
                    set(xyr.hline(1), 'xdata', xyr.p(1,[1 2]), 'ydata', xyr.p(2,[1 2]));
                    set(xyr.hline(2), 'xdata', xyr.p(1,[3 4]), 'ydata', xyr.p(2,[3 4]));
                    set(xyr.hline(3), 'xdata', xyr.p(1,[1 3]), 'ydata', xyr.p(2,[1 3]));
                    set(xyr.hline(4), 'xdata', xyr.p(1,[2 4]), 'ydata', xyr.p(2,[2 4]));

                    % Update equations:
                    xyr.xrng = [min(xyr.p(1,:)) max(xyr.p(1,:))];
                    xyr.yrng = [min(xyr.p(2,:)) max(xyr.p(2,:))];
                    % Coefficients of the y = a*x+b line:
                    xyr.x2y = [ diff(xyr.p(2,[1 2]));
                               -det(xyr.p(:,[1 2]))  ]/diff(xyr.p(1,[1 2]));
                    % Coefficients of the x = c*y+d line:
                    xyr.y2x = [ diff(xyr.p(1,[1 2]));
                                det(xyr.p(:,[1 2]))  ]/diff(xyr.p(2,[1 2]));
            end
        end
        
        %% Draw rectangular ROI
        function roiCreateRectangle(xyr)
            
            cpos = get(gca, 'currentPoint');
            if xyr.clicks == 1
                xyr.p(:,1) = cpos(1,1:2)';
                % Clip the cursor position by the axes limits:
                clip = [ xyr.p(1,1) - xyr.axlims(1)
                        -xyr.p(1,1) + xyr.axlims(2)
                         xyr.p(2,1) - xyr.axlims(3)
                        -xyr.p(2,1) + xyr.axlims(4) ];
                clipIx = find(clip < 0); % check if x or y are out of the axes box.
                if clipIx
                    dim = (clipIx>2) + 1; % identify which axis is out of the box.
                    xyr.p(dim,1) = xyr.axlims(clipIx);
                end

                % Create the four lines:
                xyr.hline(1) = plot(xyr.p([1,1],1), xyr.p([2,2],1), xyr.lineStyle,... 
                                    'color', xyr.lineColor, 'lineWidth', xyr.lineWidth);
                xyr.hline(2) = plot(xyr.p([1,1],1), xyr.p([2,2],1), xyr.lineStyle,... 
                                    'color', xyr.lineColor, 'lineWidth', xyr.lineWidth);
                xyr.hline(3) = plot(xyr.p([1,1],1), xyr.p([2,2],1), xyr.lineStyle,... 
                                    'color', xyr.lineColor, 'lineWidth', xyr.lineWidth);
                xyr.hline(4) = plot(xyr.p([1,1],1), xyr.p([2,2],1), xyr.lineStyle,... 
                                    'color', xyr.lineColor, 'lineWidth', xyr.lineWidth);

                % Activate the mouse motion callback:
                set(xyr.hfig, 'windowButtonMotionFcn', @(src,evt) roi_bmcb(xyr,src,evt) );
            else
                xyr.clicks = 0;

                % Restore figure settings:
                set(xyr.hfig, 'windowButtonMotionFcn', xyr.old_bmcb );
                set(xyr.hfig, 'windowButtonUpFcn',     xyr.old_bucb );
                set(xyr.hfig, 'windowButtonDownFcn',   xyr.old_bdcb );
                set(xyr.hfig, 'pointer', xyr.old_fpointer);
                set(gca, 'NextPlot', xyr.old_NextPlot);

                % Compute the x- and y- ranges:
                xyr.xrng = [min(xyr.p(1,:)) max(xyr.p(1,:))];
                xyr.yrng = [min(xyr.p(2,:)) max(xyr.p(2,:))];

                % Activate interaction:
                set(xyr.hline, 'buttonDownFcn', @(src,evt) line_bdcb(xyr,src,evt));
            end                        
        end
        
        function roiDrawRectangle(xyr)
            cpos = get(gca, 'currentPoint');
            if xyr.clicks == 1
                newpos = cpos(1,1:2)';
                % Clip the cursor position by the axes limits:
                clip = [ newpos(1) - xyr.axlims(1)
                        -newpos(1) + xyr.axlims(2)
                         newpos(2) - xyr.axlims(3)
                        -newpos(2) + xyr.axlims(4) ];
                clipIx = find(clip < 0, 1); % check if x or y are out of the axes box.
                if isempty(clipIx)
                    xyr.p(:,2) = newpos;
                    % Update the roi lines:
                    set(xyr.hline(1), 'xdata', xyr.p(1,1:2), 'ydata', xyr.p(2,[1 1]));
                    set(xyr.hline(2), 'xdata', xyr.p(1,1:2), 'ydata', xyr.p(2,[2 2]));
                    set(xyr.hline(3), 'xdata', xyr.p(1,[1 1]), 'ydata', xyr.p(2,1:2));
                    set(xyr.hline(4), 'xdata', xyr.p(1,[2 2]), 'ydata', xyr.p(2,1:2));
                end
            else
                disp('hey, you shouldn''t ever see this message.');
            end                        
        end
        
        %% Draw parallelogram ROI
        function roiCreateParallelogram(xyr)
            
            cpos = get(gca, 'currentPoint');
            switch xyr.clicks
                case 1
                    xyr.p(:,1) = cpos(1,1:2)';
                    % Clip the cursor position by the axes limits:
                    clip = [ xyr.p(1,1) - xyr.axlims(1)
                            -xyr.p(1,1) + xyr.axlims(2)
                             xyr.p(2,1) - xyr.axlims(3)
                            -xyr.p(2,1) + xyr.axlims(4) ];
                    clipIx = find(clip < 0); % check if x or y are out of the axes box.
                    if clipIx
                        dim = (clipIx>2) + 1; % identify which axis is out of the box.
                        xyr.p(dim,1) = xyr.axlims(clipIx);
                    end
                        
                    % Plot the principle line:
                    xyr.hline(1) = plot(xyr.p([1,1],1), xyr.p([2,2],1), xyr.lineStyle,...
                                        'color', xyr.lineColor, 'lineWidth', xyr.lineWidth);
                    set(xyr.hfig, 'windowButtonMotionFcn', @(src,evt) roi_bmcb(xyr,src,evt) );
                case 2
                    % second principle line:
                    xyr.hline(2) = plot(xyr.p(1,1:2), xyr.p(2,1:2), xyr.lineStyle,... 
                                        'color', xyr.lineColor, 'lineWidth', xyr.lineWidth);
                    % side lines:
                    xyr.hline(3) = plot(xyr.p([1,1],1), xyr.p([2,2],1), xyr.lineStyle,... 
                                        'color', xyr.lineColor, 'lineWidth', xyr.lineWidth);
                    xyr.hline(4) = plot(xyr.p([1,1],2), xyr.p([2,2],2), xyr.lineStyle,... 
                                        'color', xyr.lineColor, 'lineWidth', xyr.lineWidth);
                otherwise
                    xyr.clicks = 0;
                    
                    % Restore figure settings:
                    set(xyr.hfig, 'windowButtonMotionFcn', xyr.old_bmcb );
                    set(xyr.hfig, 'windowButtonUpFcn',     xyr.old_bucb );
                    set(xyr.hfig, 'windowButtonDownFcn',   xyr.old_bdcb );
                    set(xyr.hfig, 'pointer', xyr.old_fpointer);
                    set(gca, 'NextPlot', xyr.old_NextPlot);
                    
                    % Get the coefficients of the principle ROI line (y = a*x+b; x = c*y+d):
                    xyr.xrng = [min(xyr.p(1,:)) max(xyr.p(1,:))];
                    xyr.yrng = [min(xyr.p(2,:)) max(xyr.p(2,:))];
                    % Coefficients of the y = a*x+b line:
                    xyr.x2y = [ diff(xyr.p(2,[1 2]));
                               -det(xyr.p(:,[1 2]))  ]/diff(xyr.p(1,[1 2]));
                    % Coefficients of the x = c*y+d line:
                    xyr.y2x = [ diff(xyr.p(1,1:2));
                                det(xyr.p(:,[1 2]))  ]/diff(xyr.p(2,[1 2]));
                    
                    % Activate interaction:
                    set(xyr.hline, 'buttonDownFcn', @(src,evt) line_bdcb(xyr,src,evt));
            end            
        end
        
        function roiDrawParallelogram(xyr)
            cpos = get(gca, 'currentPoint');
            switch xyr.clicks
                case 1
                    newpos = cpos(1,1:2)';
                    % Clip the cursor position by the axes limits:
                    clip = [ newpos(1) - xyr.axlims(1)
                            -newpos(1) + xyr.axlims(2)
                             newpos(2) - xyr.axlims(3)
                            -newpos(2) + xyr.axlims(4) ];
                    clipIx = find(clip < 0, 1); % check if x or y are out of the axes box.
                    if isempty(clipIx)
                        xyr.p(:,2) = newpos;
                        % Update the principle line:
                        set(xyr.hline(1), 'xdata', xyr.p(1,1:2), 'ydata', xyr.p(2,1:2));
                    end
                case 2
                    dx = cpos(1,1)-xyr.p(1,2);
                    dy = cpos(1,2)-xyr.p(2,2);
                    if abs(dy)/diff(ylim) > abs(dx)/diff(xlim)
                        % vertical extrude:
                        xyr.type = 2;
                        xyr.p(:,3:4) = xyr.p(:,1:2) + [0 0; 1 1]*dy;
                    else
                        % horizontal extrude:
                        xyr.type = 1;
                        xyr.p(:,3:4) = xyr.p(:,1:2) + [1 1; 0 0]*dx;
                    end
                    % update second line:
                    set(xyr.hline(2), 'xdata', xyr.p(1,3:4), 'ydata', xyr.p(2,3:4));
                    % and side lines:
                    set(xyr.hline(3), 'xdata', xyr.p(1,[1,3]), 'ydata', xyr.p(2,[1,3]));
                    set(xyr.hline(4), 'xdata', xyr.p(1,[2,4]), 'ydata', xyr.p(2,[2,4]));
                case 3
                    disp('hey, you shouldn''t ever see this message.');
            end            
        end
    end
end