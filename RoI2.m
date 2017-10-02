classdef RoI2 < handle
% Interactive tool for specifying a 2D region of interest (ROI).
%
% Usage
% =====
%   roi = RoI2
%   roi = RoI2(hfig)
%
% Input (optional)
% ----------------
%  hfig     - handle of the figure for which a RoI2 tool should be created. Default, current figure (gcf).
%
% Properties
% ==========
%  shape    - scalar: 0 - rectangular region;
%                     1 - parallelogram with an x- or y-axis parallel side.
%                         I.e., either horizontally or vertically extruded.
%  xrng     - 2-vector of [min max] x-coordinate of the ROI bounding box.
%  yrng     - 2-vector of [min max] y-coordinate of the ROI bounding box.
%  p        - 2-by-k matrix of [x; y] coordinates of k points defining the ROI. 
%             For the rectangular shape, k = 2. For parallelogram, k = 4.
%  height   - heigth and
%  width      width of the ROI.
%  p_ix     - points, and x/y ranges of the ROI 
%  xrng_ix    in the units of image indices.
%  yrng_ix 
%  userFcn  - function handle of a user-supplied function (see below).
%
% Methods
% =======
%  [X, Y] = roi.samplegrid(dx, dy)      - Generate a 2D grid sampling the ROI with given dx, dy (for now, supported by parallelogram ROIs only).
%  [X, Y] = roi.samplegrid()            - Generate a 2D sampling grid at image resolution.
%  D = roi.resample(dx, dy)             - Resample the ROI on the sampling grid defined by dx and dy by means of nearest neighbour interpolation.
%  D = roi.resample()                   - Resample the ROI at the resolution of the underlying image.
%  [D, xdata, ydata] = roi.resample()   - Extract ROI values and corresponding coordinates.
%
% User function
% =============
%  userFcn = f(src, evt)
%   src - the RoI2 object
%   evt - one of these strings: 'roi2_created_rectangle', 'roi2_created_parallelogram', 'roi2_resize', 'roi2_resized', 'roi2_move', 'roi2_moved', 'roi2_deleted'.
%
% Example:
% 1) Basic usage. 
%    figure; imagesc(peaks(100)); roi = RoI2
%
% 2) User function:
%    roi = RoI2; roi.userFcn = @(src,evt) disp(evt);
%
% 3) Sampling grid:
%    figure; imagesc(peaks(50)); roi = RoI2;     % Specify a parallelogram ROI.
%    [X, Y] = roi.samplegrid; 
%    hold on; plot(X(:), Y(:), 'r.');           % Visualize sampling grid.
%
% 4) ROI resampling
%    figure; imagesc(peaks(50)); roi = RoI2;     % Specify a parallelogram ROI.
%    D = roi.resample;
%    figure; imagesc(D);

    %% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876
    
    properties
        p           % Depends on the shape: 
                    %  in rectangular ROI shape (shape = 0), p is a  2x2 matrix of [p_tl p_br] points;
                    %  in parallelogram shape (shape = 1), p is a 4x4 matrix of of end points of 
                    %  the principle lines, [p11 p12 p21 p22].
        xrng        % ROI x range.
        yrng        % ROI y range.
        x2y         % 2-vector of coefficients, [a; b], of the equation y(x) = a*x+b.
        y2x         % 2-vector of coefficients, [c; d], of the equation x(y) = c*y+d.
        lineStyle   % style of the line.
        lineColor   % color of the lines.
        lineWidth   % width of the line.
        userFcn     % user-defined function.
    end
    properties(SetObservable)
        shape        % ROI shape: 0 - rectangular, 1 - parallelogram.
    end
    properties(Dependent)
        height
        width
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
        type        % type of the parallelogram (shape = 1): 1 -  horizontaly, 2 - verticaly extruded.
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
        function xyr = RoI2(hfig)
            
            narginchk(0,1);
            % Parse input:
            if nargin == 0
                xyr.hfig  = gcf;
            elseif nargin == 1 
                xyr.hfig = hfig;
            end
                        
            % Create toggle buttons:
            rectIcon_fname = 'roi2Icon_rect.mat';
            parIcon_fname = 'roi2Icon_par.mat';

            rectIcon = load(fullfile(fileparts(mfilename('fullpath')),'icons', rectIcon_fname));
            parIcon = load(fullfile(fileparts(mfilename('fullpath')),'icons', parIcon_fname));
            
            % Look if the buttons are already there:
            xyr.htbar = findall(xyr.hfig, 'Tag', 'FigureToolBar');
            roiRectBtn = findall(xyr.htbar, 'Tag', 'roi2_rectangle_btn');
            roiParBtn = findall(xyr.htbar, 'Tag', 'roi2_parallelogram_btn');
            if ~isempty(roiRectBtn)
                % Remove previous roi lines if any:
                delete(findall(xyr.hfig, 'Tag', 'roi2_line'));
                xyr.hbtn = roiRectBtn;
                set(xyr.hbtn, 'onCallback',  @(src,evt) roiOn(xyr,src,evt),...
                              'offCallback', @(src,evt) roiOff(xyr,src,evt),...
                              'CData', rectIcon.cdata,...
                              'State', 'off',...
                              'UserData', 1);
            else
                xyr.hbtn = uitoggletool(xyr.htbar(1),  'CData', rectIcon.cdata, ...
                                                       'onCallback',  @(src,evt) roiOn(xyr, 0, src, evt),...
                                                       'offCallback', @(src,evt) roiOff(xyr, src, evt),...
                                                       'Separator', 'on',...
                                                       'tooltipString', 'Region of interest',...
                                                       'Tag', 'roi2_rectangle_btn');                
            end
            if ~isempty(roiParBtn)
                xyr.hbtn(2) = roiParBtn;
                set(xyr.hbtn(2), 'onCallback',  @(src,evt) roiOn(xyr,src,evt),...
                                 'offCallback', @(src,evt) roiOff(xyr,src,evt),...
                                 'CData', parIcon.cdata,...
                                 'State', 'off' );
            else
                xyr.hbtn(2) =  uitoggletool(xyr.htbar(1),  'CData', parIcon.cdata, ...
                                                        'onCallback',  @(src,evt) roiOn(xyr, 1, src, evt),...
                                                        'offCallback', @(src,evt) roiOff(xyr, src, evt),...
                                                        'Separator', 'off',...
                                                        'tooltipString', 'Region of interest',...
                                                        'Tag', 'roi2_parallelogram_btn');                
            end

            % Defaults:                                
            xyr.clicks = 0;
            xyr.lineStyle = '-';
            xyr.lineColor = [.3 .3 .3];
            xyr.lineWidth = 2;
            xyr.x2y = zeros(2,1);
            xyr.y2x = zeros(2,1);
            xyr.type = 0;
            xyr.axlims = axis;
            
            % If a figure has an image, grab its handle:
            xyr.himg = findobj(xyr.hfig, 'type', 'image');
            if length(xyr.himg) > 1
                warning('RoI2: can''t handle multiple images in figure.');
                xyr.hbtn.Enable = 'off';
                return;
            end
           
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
            
            % Listeners:
            addlistener(xyr, 'shape', 'PostSet', @(src, evt) xyr.shape_PostSet_cb);
        end
        
        %% Destructor
        function delete(xyr)
            
            % Delete the tool's button if it was not taken over by a new RoI object:
            if ishandle(xyr.hbtn(1)) && isempty(xyr.hbtn(1).UserData), delete(xyr.hbtn); end
            % Delete the ROI.
            if ishandle(xyr.hline), delete(xyr.hline); end
            % Restore figure keyboard events:
            if ishandle(xyr.hfig)
                set(xyr.hfig, 'KeyPressFcn', xyr.old_keyPressCb, 'KeyReleaseFcn', xyr.old_keyReleaseCb);
            end
        end
        
        %% ROI On/Off callbacks
        function roiOn(xyr, shape, ~,~)
            xyr.shape = shape;
        end
        
        function roiOff(xyr,~,~)
           
            % Delete the ROI.
            if ishandle(xyr.hline), delete(xyr.hline); end
            xyr.type = 0;
            
            % Restore figure keyboard events:
            set(xyr.hfig, 'KeyPressFcn', xyr.old_keyPressCb,... 
                          'KeyReleaseFcn', xyr.old_keyReleaseCb);
            set(xyr.hfig, 'WindowButtonDownFcn', xyr.old_bdcb,...
                          'WindowButtonUpFcn',   xyr.old_bucb);
            
            % Call the user-defined function:
                if ~isempty(xyr.userFcn)
                    evt = 'roi2_deleted';
                    xyr.userFcn(xyr, evt);
                end
        end
        
        %% Create new ROI
        function xyr = newroi(xyr)
            
            % Disable other interactive tools:
            xyr.interactivesOff(xyr.hfig);
            
            % Delete the previous roi:
            if ishandle(xyr.hline)
                delete(xyr.hline);
            end
                        
            % Store previous interaction callbacks:
            xyr.old_bdcb = get(xyr.hfig, 'WindowButtonDownFcn');
            xyr.old_bmcb = get(xyr.hfig, 'WindowButtonMotionFcn');
            xyr.old_bucb = get(xyr.hfig, 'WindowButtonUpFcn');
            xyr.old_keyPressCb   = get(xyr.hfig, 'KeyPressFcn');
            xyr.old_keyReleaseCb = get(xyr.hfig, 'KeyReleaseFcn');


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
        
        %% Window button up callback
        function roi_bucb(xyr,~,~)
            
            xyr.clicks = xyr.clicks+1;
            
            switch xyr.shape
                case 0
                    roiCreateRectangle(xyr);
                case 1
                    roiCreateParallelogram(xyr);
            end
        end
        
        %% Window button motion function
        function roi_bmcb(xyr,~,~)
            
            switch xyr.shape
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
            
            switch xyr.shape
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
        
            set(xyr.hfig, 'windowButtonMotionFcn', xyr.old_bmcb,...
                          'WindowButtonUpFcn',     xyr.old_bdcb,...  
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
            
            % Clip ROI to the axes limits:
            if all([new_p(1,:)>=xyr.axlims(1), new_p(1,:)<=xyr.axlims(2)])
                xyr.p(1,:) = new_p(1,:);
            end
            if all([new_p(2,:)>=xyr.axlims(3), new_p(2,:)<=xyr.axlims(4)])
                xyr.p(2,:) = new_p(2,:);
            end
            xyr.update();

            % Call the user-defined function:
            if ~isempty(xyr.userFcn)
                evt = 'roi2_move';
                xyr.userFcn(xyr, evt);
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
            switch xyr.shape
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
                xyr.p = zeros(2);
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
                
                % Restore figure settings:
                set(xyr.hfig, 'windowButtonMotionFcn', xyr.old_bmcb );
                set(xyr.hfig, 'windowButtonUpFcn',     xyr.old_bucb );
%                 set(xyr.hfig, 'windowButtonDownFcn',   xyr.old_bdcb );
                set(xyr.hfig, 'pointer', xyr.old_fpointer);
                set(gca, 'NextPlot', xyr.old_NextPlot);
                
                % Activate interaction:
                set(xyr.hline, 'buttonDownFcn', @(src,evt) line_bdcb(xyr,src,evt));
                set(xyr.hfig, 'windowButtonDownFcn', @(src,evt) roiMove_bdcb(xyr, src,evt));
                
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
                    xyr.p = zeros(2,4);
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
%                     set(xyr.hfig, 'windowButtonDownFcn',   xyr.old_bdcb );
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
                        evt = 'roi2_created_parallelogram';
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
                
        %% Sample ROI
        function [D, xdata, ydata] = resample(xyr, varargin)
            
            % Sanity check:
            if ~ishandle(xyr.himg)
                warning('Image not found.')
                return;
            end
            
            switch xyr.shape
                case 0      % Rectangular ROI => simple extraction.
                    x_ix = xyr.xrng_ix(1):xyr.xrng_ix(2);
                    y_ix = xyr.yrng_ix(1):xyr.yrng_ix(2);
                    D = xyr.himg.CData(y_ix, x_ix);
                    if nargout > 1
                        try
                            xdata = xyr.himg.XData(x_ix);
                            ydata = xyr.himg.YData(y_ix);
                        catch ME
                            warning('RoI2:inconsistentAxesData', 'RoI2: Couldn''t extract axes coordinates. %s', ME.message);
                            xdata = []; ydata = [];
                        end
                    end
                case 1
                    [X, Y] = xyr.samplegrid(varargin{:});
                    % Nearest neighbour search:
                    x_ix = floor( (X(:) - xyr.p0(1))/xyr.dxx ) + 1;
                    y_ix = floor( (Y(:) - xyr.p0(2))/xyr.dyy ) + 1;
                    D = xyr.himg.CData(sub2ind(size(xyr.himg.CData), y_ix, x_ix));
                    D = reshape(D, size(X));
                    if nargout > 1
                        switch xyr.type
                            case 1
                                xdata = 1:size(X,2);
                                ydata = Y(:,1);
                            case 2
                                xdata = X(1,:);
                                ydata = 1:size(Y,1);
                        end                        
                    end
            end
        end
        
        function [X, Y] = samplegrid(xyr, dx, dy)
            
            % Parse input:
            if nargin == 1
                dx = xyr.dxx;
                dy = xyr.dyy;
            elseif nargin == 2
                dy = xyr.dyy;
            end
            
            % Create sample grid: a set of lines each having nPoints.
            switch xyr.shape
                case 0
                    warning('RoI2: ROI re-sampling for rectangular ROIs isn''t supported yet.');
                    X = [];
                    Y = [];
                case 1
                    if xyr.type == 1
                        nPoints = round(xyr.height/dy);
                        nLines  = round(xyr.width/dx);
                        X = zeros(nPoints, nLines); Y = X;
                    elseif xyr.type == 2
                        nPoints = round(xyr.width/dx);
                        nLines  = round(xyr.height/dy);
                        X = zeros(nLines, nPoints); Y = X;
                    else
                        error('RoI2: unrecognized type parameter.');
                    end                    
                    tp = linspace(0, 1, nPoints);   % parametrization variable.
                    tl = linspace(0, 1, nLines);
                    for ii = 1:nLines
                        tt = tl(ii);
                        p1 = (1-tt)*xyr.p(:,1) + tt*xyr.p(:,3); % end points of the principle diagonal line.
                        p2 = (1-tt)*xyr.p(:,2) + tt*xyr.p(:,4);
                        pts = (1-tp).*p1 + tp.*p2;
                        if xyr.type == 1
                            X(:,ii) = pts(1,:)'; Y(:,ii) = pts(2,:)';
                        elseif xyr.type == 2
                            X(ii,:) = pts(1,:); Y(ii,:) = pts(2,:);
                        else
                            error('RoI2: unrecognized type parameter.');
                        end
                    end
            end
        end
    end
    %% Setters & Getters
    methods
        function val = get.width(xyr)
            switch xyr.shape
                case 0
                    val = abs(diff(xyr.p(1,:)));
                case 1
                    if xyr.type == 1
                        val = abs(diff(xyr.p(1,[1, 3])));
                    elseif xyr.type == 2
                        val = abs(diff(xyr.p(1,[1, 2])));
                    else
                        error('RoI2: undefined type parameter.');
                    end
                    
            end
        end
        
        function val = get.height(xyr)
            switch xyr.shape
                case 0
                    val = abs(diff(xyr.p(2,:)));
                case 1
                    if xyr.type == 1
                        val = abs(diff(xyr.p(2,[1, 2])));
                    elseif xyr.type == 2
                        val = abs(diff(xyr.p(2,[1, 3])));
                    else
                        error('RoI2: undefined type parameter.');
                    end
            end            
        end
    end
    
    %% Listeners
    methods
        function shape_PostSet_cb(xyr)
            
            % Toggle buttons.
            % Turn off all buttons:
            if ~isempty(xyr.hbtn) && length(xyr.hbtn) > 1 && ishandle(xyr.hbtn(1))
                for ii = 1:length(xyr.hbtn)
                    xyr.hbtn(ii).State = 'off';
                end
            else
                return;
            end
            
            % Turn on the one according to the shape parameter:
            xyr.hbtn(min(xyr.shape+1, length(xyr.hbtn))).State = 'on';
            
            % Create new ROI:
            newroi(xyr);
        end
    end
    
        %% Static
    methods(Static)
        function interactivesOff(hfig)
        % Switch off interactive tools.
            curfig = gcf;
            figure(hfig)
            plotedit off, zoom off, pan off, rotate3d off, datacursormode off, brush off
            figure(curfig)
        end
        
        function escape(hfig)
        % Emergency: clear all interaction callbacks.
            if ishandle(hfig)                
                set(hfig, 'WindowButtonMotionFcn', [], ...
                          'WindowButtonUpFcn',     [], ... 
                          'WindowButtonDownFcn',   [], ...
                          'KeyPressFcn',           [], ...
                          'KeyReleaseFcn',         [] );
            end            
        end
    end
end