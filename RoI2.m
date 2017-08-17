classdef RoI2 < handle
% Interactive tool for specifying a 2D region of interest (ROI).
%
% Usage
% =====
%   roi = RoI2
%   roi = RoI2(type)
%   roi = RoI2(type, hfig)
%
% Input (optional)
% ----------------
%  type     - 0 - rectangular, 1 - parallelogram region. Default, 0.
%  hfig     - handle of the figure for which a RoI2 tool should be created. Default, current figure (gcf).
%
% User function
% -------------
%  userFcn = f(src, evt)
%   src - the RoI2 object
%   evt - one of these strings: 'roi2_created_rectangle', 'roi2_created_parallelogram', 'roi2_resize', 'roi2_resized', 'roi2_move', 'roi2_moved', 'roi2_deleted'.
%
% Example:
% 1) Basic usage. 
%    figure; imagesc(peaks(100)); roi = RoI2
%    figure; imagesc(peaks(200)); roi = RoI2(1)
% 2) User function:
%    roi = RoI2; roi.userFcn = @(src,evt) disp(evt);

    %% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876
    
    properties
        p           % Depends on the type: 
                    %  in rectangular ROI type (type = 0), p is a  2x2 matrix of [p_tl p_br] points;
                    %  in parallelogram type (type = 1), p is a 4x4 matrix of of end points of 
                    %  the principle lines, [p11 p12 p21 p22].
        xrng        % ROI x range.
        yrng        % ROI y range.
        x2y         % 2-vector of coefficients, [a; b], of the equation y(x) = a*x+b.
        y2x         % 2-vector of coefficients, [c; d], of the equation x(y) = c*y+d.
        lineStyle   % style of the line.
        lineColor   % color of the lines.
        lineWidth   % width of the line.
        type        % ROI type: 0 - rectangular, 1 - parallelogram.
        userFcn     % user-defined function.
    end
    
    properties(Hidden = true)
        % Various handles:
        hfig    % figure handle.
        htbar   % toolbar handle.
        hbtn    % the tool's toolbar button.
        hline   % array of 4 line handles: [top, bottom, left, right].
        tag_line = 'roi2_line'
        
        % Previous state of the figure:
        old_bdcb
        old_bucb
        old_bmcb
        old_keyPressCb
        old_keyReleaseCb
        old_fpointer
        old_NextPlot
        axlims
        
        % Interactions:
        clicks      % clicks counter.
        shape       % shape of the parallelogram (type = 1): 1 -  horizontaly, 2 - verticaly extruded.
        lineIx      % index of the selected line in the hline array.
        old_cpos    % store cursor position for line movement.
        old_p       % store the ROI points matrix, p.
    end
    
    % Image related properties:
    properties(Hidden = true)
        himg        % handle of an image if it exist in the figure.
        p0          % coordinates of the image origin.
        dxx         % increment on the x-axis.
        dyy         % increment on the y-axis.
        
    end
    
    properties
        p_ix        % matrix of image indices corresponding to p.
        xrng_ix     % image indicies corresponding to xrng and
        yrng_ix     % yrng.
    end
    
    methods
        %% Constructor
        function xyr = RoI2(type, hfig)
            
            % Parse input:
            if nargin == 0
                xyr.hfig  = gcf;
                xyr.type = 0;
            elseif nargin == 1 
                xyr.hfig = gcf;
                xyr.type = type;
            else
                xyr.hfig = hfig;
                xyr.type = type;
            end
            
            % Create toggle button:
            if xyr.type == 0
                icon_fname = 'roi2Icon_rect.mat';
            elseif xyr.type == 1
                icon_fname = 'roi2Icon_par.mat';
            end
            xyroiIcon = load(fullfile(fileparts(mfilename('fullpath')),'icons', icon_fname));
            
            % Look if the button is already there:
            xyr.htbar = findall(xyr.hfig, 'Type', 'uitoolbar');
            roiBtn = findall(xyr.htbar, 'Tag', 'roi2_btn');
            if ~isempty(roiBtn)
                % Remove previous roi lines if any:
                delete(findall(xyr.hfig, 'Tag', 'roi2_line'));
                xyr.hbtn = roiBtn;
                set(xyr.hbtn, 'onCallback',  @(src,evt) roiOn(xyr,src,evt),...
                              'offCallback', @(src,evt) roiOff(xyr,src,evt),...
                              'CData', xyroiIcon.cdata,...
                              'State', 'off',...
                              'UserData', xyr.type);
            else
                xyr.hbtn =  uitoggletool(xyr.htbar(1),  'CData', xyroiIcon.cdata, ...
                                                        'onCallback',  @(src,evt) roiOn(xyr,src,evt),...
                                                        'offCallback', @(src,evt) roiOff(xyr,src,evt),...
                                                        'Separator', 'on',...
                                                        'tooltipString', 'Region of interest',...
                                                        'Tag', 'roi2_btn');                
            end
            % Defaults:                                
            xyr.clicks = 0;
            xyr.lineStyle = '-';
            xyr.lineColor = [.3 .3 .3];
            xyr.lineWidth = 2;
            xyr.x2y = zeros(2,1);
            xyr.y2x = zeros(2,1);
            xyr.shape = 0;
            xyr.axlims = axis;
            
            % If a figure has an image, grab its handle:
            xyr.himg = findobj(xyr.hfig, 'type', 'image');
           
            % Get scaling info about the image:
            if ishandle(xyr.himg)
               xyr.p0 = [xyr.himg.XData(1); xyr.himg.YData(1)];

               [nRows, nCols] = size(xyr.himg.CData);
               if length(xyr.himg.XData) == nCols
                   xyr.dxx = diff(xyr.himg.XData(1:2));
               elseif length(xyr.himg.XData) == 2
                   % Create xdata vector:
                   xyr.himg.XData = linspace(xyr.himg.XData(1), xyr.himg.XData(2), nCols);
                   xyr.dxx = diff(xyr.himg.XData(1:2));
               else
                   warning('The length of the X-coordinate vector doesn''t match the number of columns in the image.');
                   xyr.dxx = diff(xyr.himg.XData([1,end]) )/( nCols - 1 );
               end

               if length(xyr.himg.YData) == nRows
                   xyr.dyy = diff(xyr.himg.YData(1:2));
              elseif length(xyr.himg.YData) == 2
                   % Create ydata vector:
                   xyr.himg.YData = linspace(xyr.himg.YData(1), xyr.himg.YData(2), nRows);
                   xyr.dyy = diff(xyr.himg.YData(1:2));
               else
                   warning('The length of the Y-coordinate vector doesn''t match the number of rows in the image.');
                   xyr.dyy = diff(xyr.himg.XData([1,end]))/( nRows - 1 );
               end
            end
        end
        
        %% Destructor
        function delete(xyr)
            
            % Delete the tool's button if it was not taken over by a new RoI object:
            if ishandle(xyr.hbtn) && isempty(xyr.hbtn.UserData), delete(xyr.hbtn); end
            % Delete the ROI.
            if ishandle(xyr.hline), delete(xyr.hline); end
            % Restore figure keyboard events:
            if ishandle(xyr.hfig)
                set(xyr.hfig, 'KeyPressFcn', xyr.old_keyPressCb, 'KeyReleaseFcn', xyr.old_keyReleaseCb);
            end
        end
        
        %% ROI On/Off callbacks
        function roiOn(xyr,~,~)
            newroi(xyr);
        end
        
        function roiOff(xyr,~,~)
           
            % Delete the ROI.
            if ishandle(xyr.hline), delete(xyr.hline); end
            xyr.shape = 0;
            xyr.hbtn.State = 'off';
            
            % Restore figure keyboard events:
            set(xyr.hfig, 'KeyPressFcn', xyr.old_keyPressCb, 'KeyReleaseFcn', xyr.old_keyReleaseCb);
            
            % Call the user-defined function:
                if ~isempty(xyr.userFcn)
                    evt = 'roi2_deleted';
                    xyr.userFcn(xyr, evt);
                end
        end
        
        %% Create new ROI
        function xyr = newroi(xyr)
            
            % Disable other interactive tools:
            zoom off, pan off, datacursormode off, plotedit off
            
            % Delete the previous roi:
            if ishandle(xyr.hline)
                delete(xyr.hline);
            end
                        
            % Store previous interaction callbacks:
            xyr.old_bdcb = get(gcf,'WindowButtonDownFcn');
            xyr.old_bmcb = get(gcf,'WindowButtonMotionFcn');
            xyr.old_bucb = get(gcf,'WindowButtonUpFcn');
            xyr.old_keyPressCb   = get(gcf, 'KeyPressFcn');
            xyr.old_keyReleaseCb = get(gcf, 'KeyReleaseFcn');


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
            set(xyr.hfig, 'windowButtonUpFcn', @(src,evt) roi_bucb(xyr,src,evt), ...
                          'KeyPressFcn',   @(src,evt) fkpcb(xyr,src,evt), ...
                          'KeyReleaseFcn', @(src,evt) fkrcb(xyr,src,evt) );
            hold on;
        end
        
        %% Window button down callback
        function roi_bucb(xyr,~,~)
            
            xyr.clicks = xyr.clicks+1;
            
            switch xyr.type
                case 0
                    roiCreateRectangle(xyr);
                case 1
                    roiCreateParallelogram(xyr);
            end
        end
        
        %% Window button motion function
        function roi_bmcb(xyr,~,~)
            
            switch xyr.type
                case 0
                    roiDrawRectangle(xyr);
                case 1
                    roiDrawParallelogram(xyr);
            end
        end
        
        %% Line button down callback
        function line_bdcb(xyr, src, ~)
            xyr.lineIx = find(src == xyr.hline);
            cpos = get(gca, 'currentPoint');
            xyr.old_cpos = cpos(1,1:2)';
            xyr.old_p = xyr.p;
            
            % Store previous interaction callbacks:
            xyr.old_bdcb = get(gcf,'WindowButtonDownFcn');
            xyr.old_bmcb = get(gcf,'WindowButtonMotionFcn');
            xyr.old_bucb = get(gcf,'WindowButtonUpFcn');
            
            % Update axes limits:
            xyr.axlims = axis;
            
            % Set new interaction callbacks:
            set(xyr.hfig, 'windowButtonMotionFcn', @(src,evt) line_bmcb(xyr,src,evt),...
                          'windowButtonUpFcn',     @(src,evt) line_bucb(xyr,src,evt) );
        end
        
        %% Line button motion callback
        function line_bmcb(xyr,~,~)
            cpos = get(gca, 'currentPoint');
            cpos = cpos(1,1:2)';
            dxdy = cpos - xyr.old_cpos;     % shift vector.
            
            switch xyr.type
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
                        switch xyr.shape
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
               
               % Call the user-defined function:
               if ~isempty(xyr.userFcn)
                   evt = 'roi2_resize';
                   xyr.userFcn(xyr, evt);
               end
            end
        end
        
        %% Line button up callback
        function line_bucb(xyr,~,~)
            % Restore figure settings:
            set(xyr.hfig, 'windowButtonMotionFcn', xyr.old_bmcb, ...
                          'windowButtonUpFcn',     xyr.old_bucb );
            % Call the user-defined function:
            if ~isempty(xyr.userFcn)
                evt = 'roi2_resized';
                xyr.userFcn(xyr, evt);
            end
        end
        
        %% ROI move callbacks
        function roiMove_bdcb(xyr,~,~)
        % Right Button down callback.
        
            buttonType = get(gcbf, 'SelectionType');
            if strcmpi(buttonType, 'alt') || strcmpi(buttonType, 'open')
                cpos = get(gca, 'currentPoint');
                cpos = cpos(1,1:2)';
                
                if all(prod([cpos cpos] - [xyr.xrng; xyr.yrng], 2) < 0) 
                    set(gcf,'Pointer','fleur');
                
                    xyr.old_cpos = cpos;
                    xyr.old_p = xyr.p;
            
                    % Update axes limits:
                    xyr.axlims = axis;
            
                    % Set the mouse motion function:
                    set(xyr.hfig, 'windowButtonMotionFcn', @(src,evt) roiMove_bmcb(xyr,src,evt), ...
                                  'windowButtonUpFcn',     @(src,evt) roiMove_bucb(xyr,src,evt) );
                end
            end
        end
        
        function roiMove_bucb(xyr,~,~)
        % Movement complete.
        
            set(xyr.hfig, 'windowButtonMotionFcn', xyr.old_bmcb, ...
                          'Pointer', 'arrow');
                      
            % Call the user-defined function:
            if ~isempty(xyr.userFcn)
                evt = 'roi2_moved';
                xyr.userFcn(xyr, evt);
            end
        end
        
        function roiMove_bmcb(xyr,~,~)
        % Button motion callback.
            cpos = get(gca, 'currentPoint');
            cpos = cpos(1,1:2)';
            shiftV = cpos - xyr.old_cpos;     % shift vector.
            
            % New coordinates:
            v1 = ones(1, size(xyr.p, 2));
            new_p = xyr.old_p + shiftV*v1;
            
            % Check if the ROI exceeds axes limits:
            if all([new_p(1,:)>=xyr.axlims(1), new_p(1,:)<=xyr.axlims(2),...
                    new_p(2,:)>=xyr.axlims(3), new_p(2,:)<=xyr.axlims(4)])
                xyr.p = new_p;
                xyr.update();
               
                % Call the user-defined function:
                if ~isempty(xyr.userFcn)
                    evt = 'roi2_move';
                    xyr.userFcn(xyr, evt);
                end
            end
        end
        
        %% Keyboard events callbacks
        function fkpcb(xyr, ~, evt)
        % Handler for the figure keypress event.
            if false % strcmpi(evt.Modifier,'control')
                cpos = get(gca, 'currentPoint');
                cpos = cpos(1,1:2)';
                
                % If the pointer is within the ROI:
                if all(prod([cpos cpos] - [xyr.xrng; xyr.yrng], 2) < 0) 
                    set(gcf,'Pointer','fleur');
                    
                    % Store previous interaction callbacks:
                    xyr.old_bdcb = get(gcf,'WindowButtonDownFcn');
                    xyr.old_bucb = get(gcf,'WindowButtonUpFcn');
                    xyr.old_bmcb = get(gcf,'WindowButtonMotionFcn');
                    
                    % Set new interaction callbacks:
                    set(xyr.hfig, 'windowButtonDownFcn', @(src,evt) roiMove_bdcb(xyr,src,evt), ...
                                  'windowButtonUpFcn',   @(src,evt) roiMove_bucb(xyr,src,evt) );

                end
            elseif strcmpi(evt.Key, 'escape')
                % Clear window interactions:
                set(xyr.hfig, 'windowButtonMotionFcn', '',...
                              'windowButtonDownFcn', @(src,evt) roiMove_bdcb(xyr,src,evt),...  
                              'windowButtonUpFcn', '');
            end
        end

        function fkrcb(xyr,~,evt)
        % Handler for the figure keyboard release event.
            set(gcf,'Pointer','arrow');
            
            if ~strcmpi(evt.Key, 'escape')
                % Restore callbacks:
                set(xyr.hfig, 'windowButtonMotionFcn', xyr.old_bmcb, ...
                              'windowButtonUpFcn',     xyr.old_bucb, ...
                              'windowButtonDownFcn',   xyr.old_bdcb);
            end
        end
        
        %% Update ROI
        function update(xyr)
            
            % Update plot:
            switch xyr.type
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
                   
                    % Coefficients of the y = a*x+b line:
                    xyr.x2y = [ diff(xyr.p(2,[1 2]));
                               -det(xyr.p(:,[1 2]))  ]/diff(xyr.p(1,[1 2]));
                    % Coefficients of the x = c*y+d line:
                    xyr.y2x = [ diff(xyr.p(1,[1 2]));
                                det(xyr.p(:,[1 2]))  ]/diff(xyr.p(2,[1 2]));
            end
            
            % Update ranges:
            xyr.xrng = [min(xyr.p(1,:)) max(xyr.p(1,:))];
            xyr.yrng = [min(xyr.p(2,:)) max(xyr.p(2,:))];

            % Find corresponding image indices:
            if ishandle(xyr.himg)
                v1 = ones(1, size(xyr.p, 2));
                xyr.p_ix = round((xyr.p - xyr.p0*v1)./([xyr.dxx; xyr.dyy]*v1))+1;
                xyr.xrng_ix = round((xyr.xrng - [xyr.p0(1) xyr.p0(1)])./[xyr.dxx xyr.dxx])+1;
                xyr.yrng_ix = round((xyr.yrng - [xyr.p0(2) xyr.p0(2)])./[xyr.dyy xyr.dyy])+1;
            end
        end
        
        %% Rectangular ROI
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
                                    'color', xyr.lineColor, 'lineWidth', xyr.lineWidth, 'tag', xyr.tag_line);
                xyr.hline(2) = plot(xyr.p([1,1],1), xyr.p([2,2],1), xyr.lineStyle,... 
                                    'color', xyr.lineColor, 'lineWidth', xyr.lineWidth, 'tag', xyr.tag_line);
                xyr.hline(3) = plot(xyr.p([1,1],1), xyr.p([2,2],1), xyr.lineStyle,... 
                                    'color', xyr.lineColor, 'lineWidth', xyr.lineWidth, 'tag', xyr.tag_line);
                xyr.hline(4) = plot(xyr.p([1,1],1), xyr.p([2,2],1), xyr.lineStyle,... 
                                    'color', xyr.lineColor, 'lineWidth', xyr.lineWidth, 'tag', xyr.tag_line);

                % Activate the mouse motion callback:
                set(xyr.hfig, 'windowButtonMotionFcn', @(src,evt) roi_bmcb(xyr,src,evt) );
            else
                xyr.clicks = 0;
                
                % Compute the x- and y- ranges:
                xyr.xrng = [min(xyr.p(1,:)) max(xyr.p(1,:))];
                xyr.yrng = [min(xyr.p(2,:)) max(xyr.p(2,:))];
                
                % Find corresponding image indices:
                if ishandle(xyr.himg)
                    v1 = ones(1, size(xyr.p,2));
                    xyr.p_ix = round((xyr.p - xyr.p0*v1)./([xyr.dxx; xyr.dyy]*v1))+1;
                    xyr.xrng_ix = round((xyr.xrng - xyr.p0(1)*v1)./[xyr.dxx xyr.dxx])+1;
                    xyr.yrng_ix = round((xyr.yrng - xyr.p0(2)*v1)./[xyr.dyy xyr.dyy])+1;
                end

                % Restore figure settings:
                set(xyr.hfig, 'windowButtonMotionFcn', xyr.old_bmcb );
                set(xyr.hfig, 'windowButtonUpFcn',     xyr.old_bucb );
%                 set(xyr.hfig, 'windowButtonDownFcn',   xyr.old_bdcb );
                set(xyr.hfig, 'pointer', xyr.old_fpointer);
                set(gca, 'NextPlot', xyr.old_NextPlot);
                
                % Activate interaction:
                set(xyr.hline, 'buttonDownFcn', @(src,evt) line_bdcb(xyr,src,evt));
                set(xyr.hfig, 'windowButtonDownFcn', @(src,evt) roiMove_bdcb(xyr, src,evt));
                
                % Call the user-defined function:
                if ~isempty(xyr.userFcn)
                    evt = 'roi2_created_rectangle';
                    xyr.userFcn(xyr, evt);
                end
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
        
        %% Parallelogram ROI
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
                                        'color', xyr.lineColor, 'lineWidth', xyr.lineWidth, 'tag', xyr.tag_line);
                    set(xyr.hfig, 'windowButtonMotionFcn', @(src,evt) roi_bmcb(xyr,src,evt) );
                case 2
                    % second principle line:
                    xyr.hline(2) = plot(xyr.p(1,1:2), xyr.p(2,1:2), xyr.lineStyle,... 
                                        'color', xyr.lineColor, 'lineWidth', xyr.lineWidth, 'tag', xyr.tag_line);
                    % side lines:
                    xyr.hline(3) = plot(xyr.p([1,1],1), xyr.p([2,2],1), xyr.lineStyle,... 
                                        'color', xyr.lineColor, 'lineWidth', xyr.lineWidth, 'tag', xyr.tag_line);
                    xyr.hline(4) = plot(xyr.p([1,1],2), xyr.p([2,2],2), xyr.lineStyle,... 
                                        'color', xyr.lineColor, 'lineWidth', xyr.lineWidth, 'tag', xyr.tag_line);
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
                    set(xyr.hfig, 'windowButtonDownFcn', @(src,evt) roiMove_bdcb(xyr, src,evt));

                    % Call the user-defined function:
                    if ~isempty(xyr.userFcn)
                        evt = 'roi2_created_rectangle';
                        xyr.userFcn(xyr, evt);
                    end
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
                        xyr.shape = 2;
                        xyr.p(:,3:4) = xyr.p(:,1:2) + [0 0; 1 1]*dy;
                    else
                        % horizontal extrude:
                        xyr.shape = 1;
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
                
        %% Sample ROI
        function [D, xroi, yroi] = sample(xyr)
            
            % Sanity check:
            if ~ishandle(xyr.himg)
                warning('Image not found.')
                return;
            end
            
            switch xyr.type
                case 0      % Rectangular ROI => simple extraction.
                    x_ix = xyr.xrng_ix(1):xyr.xrng_ix(2);
                    y_ix = xyr.yrng_ix(1):xyr.yrng_ix(2);
                    D = xyr.himg.CData(y_ix, x_ix);
                    if nargout > 1
                        try
                            xroi = xyr.himg.XData(x_ix);
                            yroi = xyr.himg.YData(y_ix);
                        catch M
                            warning(['Couldn''t extract axes coordinates. ' M.message]);
                            xroi = []; yroi = [];
                        end
                    end
                case 1
            end
        end
        
    end
end