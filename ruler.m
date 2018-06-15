function ruler()
% Ruler tape.
%
% ruler  -  first time: creates a menu function for measurement in the current figure,
%           second time: deletes the menu function in the current figure.
%
% Measurement starts/ends when pressing/releasing the mouse button.
% A dialog box shows the measurement results.
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    hRulerBtn   = findall(gcf,'Tag','rulerBtn');
    hRulerProps = findall(gcf,'Tag','rulerProps'); 
    hxPlotBtn   = findall(gcf,'Tag','xPlotBtn'); 
    
    if (isempty(hRulerBtn))
        ht = findall(gcf,'Type','uitoolbar');
        icon = load(fullfile(fileparts(mfilename('fullpath')),'/icons/rulerIcon_triangular.mat'));
        propIcon = load(fullfile(fileparts(mfilename('fullpath')),'/icons/ruler_PropIcon.mat'));
        xPlotIcon = load(fullfile(fileparts(mfilename('fullpath')),'/icons/ruler_xPlotIcon.mat'));
        uipushtool(ht, 'CData',icon.cdata,...
                       'TooltipString','Ruler',....
                       'ClickedCallback', @rulerStart,... 
                       'Tag', 'rulerBtn',...
                       'Separator', 'on');
        uitoggletool(ht, 'OnCallback', @rulerCrossSectionPlotOn, ...
                         'OffCallback', @rulerCrossSectionPlotOff, ...
                         'CData', xPlotIcon.cdata,...
                         'TooltipString', 'Cross-section plot',...
                         'Tag', 'xPlotBtn', ...
                         'Enable', 'off');                              
        uipushtool(ht, 'ClickedCallback', @rulerPropDlg,...
                       'CData', propIcon.cdata,...
                       'TooltipString', 'Ruler properties',...
                       'Tag', 'rulerProps');

        disp('Ruler tool added.');

        % Set the mouse down function:
        datacursormode off, zoom off, pan off, plotedit off

        % Interaction functions:
        set(gcf, 'KeyPressFcn',   @rulerKeyPress, ...
                 'KeyReleaseFcn', @rulerKeyRelease);
             
        % Properties:
        lorient = '0';  % Line orientation: 0 - free, 1 - horizontal, 2 - vertical.
        gcaXlim = get(gca, 'xlim');
        gcaColor = get(gca, 'color');
        gcaXlabel = get(gca, 'xlabel');
        gcaYlabel = get(gca, 'ylabel');
        xdimLabel = 'x';
        ydimLabel = 'y';

%         timeUnits = ( min(gcaXlim) > 690e3 ); % 1 - x-axis is in 'date' format; 0 - seconds.
        xlineNPoints = 1000;
        xlineVarName = 'xline';
        xlineFcn = str2func('ruler_xlineSpectrum');        
        xlineFcnFigure = rand(1e6,1);
        xplotFigure = rand(1e6,1);
        xplotOn = 0;
        lineStyle = 'w--';
        lineEndStyle = 'w+';
        ruler = [];
    else
        % Remove the toolbar buttons:
        delete(hRulerBtn);
        delete(hxPlotBtn);
        delete(hRulerProps);
      
        % Delete the line and the info box:
        delete(findobj(gcf,'Tag','ruler.line'));
        delete(findall(gcf,'Tag','ruler.info'));
        delete(findall(gcf,'Tag','ruler.end'));

        disp('Ruler tool has been deleted.');
    end

    %% Click on the Ruler button
    function rulerStart(~,~)
    % "Ruler" button clicked callback.

    % Switch off various interactive modes:
    datacursormode off, zoom off, pan off, plotedit off
    
    % Get handle to the previous line:
    hLine = findobj(gcf,'Tag','ruler.line');
    if (~isempty(hLine))
        ruler = get(hLine,'userdata');
        % Delete the annotation box from the previous measurement:
        if isfield(ruler,'info'), delete(ruler.info); end
        
        % Remove the previous line:
        delete(hLine);
        delete(ruler.hEnds);
        
        % Disable the xPlotBtn:
        set(hxPlotBtn, 'Enable', 'off', 'State', 'off');
        xplotOn = 0;
    end

    set(gcf,'DoubleBuffer','on');
    refresh;
    

    % Create a ruler structure as a place holder for relevant information.
    % Store the current mouse events handlers:
    ruler.fun_down   = get(gcf,'WindowButtonDownFcn');
    ruler.fun_motion = get(gcf,'WindowButtonMotionFcn');
    ruler.fun_up     = get(gcf,'WindowButtonUpFcn');

    % Clear the mouse event handlers:
    set(gcf,'WindowButtonDownFcn','');
    set(gcf,'WindowButtonMotionFcn','');
    set(gcf,'WindowButtonUpFcn','');

    % Change the mouse cursor:
    ruler.figurePointer = get(gcf,'Pointer');
    set(gcf,'Pointer','crosshair');

    % Store the current hold setting:
    ruler.hold_status = ishold;

    % Prepare the annotation textbox for results display:
    ruler.info = annotation('textbox', [.13 .1 .1 .1],...
                            'String', { 'dx   :',...
                                        'dy   :',... 
                                        'dy/dx:',...
                                        'dx/dy:'
                                      },...
                            'BackgroundColor', gcaColor,...
                            'FontSize', 12, ...
                            'FontWeight', 'bold',...
                            'Tag', 'ruler.info' ...
                          );                    

    waitforbuttonpress;
    pos1 = get(gca,'currentpoint');
    hold on;
    ruler.hLine = plot([pos1(1,1) pos1(1,1)], [pos1(1,2) pos1(1,2)], lineStyle, 'LineWidth',2, 'Tag','ruler.line');
    ruler.hEnds = [ plot(pos1(1,1), pos1(1,2), lineEndStyle, 'MarkerSize',10, 'LineWidth',3, 'Tag','ruler.end');
                    plot(pos1(1,1), pos1(1,2), lineEndStyle, 'MarkerSize',10, 'LineWidth',3, 'Tag','ruler.end') ];
    
    % Save the ruler object in the 'UserData' field of the it's line object:
    set(ruler.hLine,'UserData',ruler);

    % Set the mouse events handlers:
    set(gcf,'WindowButtonMotionFcn',  @ruler_mmcb);
    set(gcf,'WindowButtonUpFcn',      @ruler_mbucb);
    set(ruler.hEnds, 'ButtonDownFcn', @rulerEnds_bdcb);
    set(ruler.hLine, 'ButtonDownFcn', @rulerLine_bdcb);
    
    % Define the labels of the x/y dimensions:
    if isempty(gcaXlabel.String), xdimLabel = 'x'; else xdimLabel = gcaXlabel.String; end
    if isempty(gcaYlabel.String), ydimLabel = 'y'; else ydimLabel = gcaYlabel.String; end
    
    end

    %% Window button motion callback
    function ruler_mmcb(src,~)
    % Ruler mouse motion callback.

        % Find the line:
        hLine = findobj(src, 'Tag', 'ruler.line');
        ruler = get(hLine,'UserData');

        % Upldate the line:
        pos2 = get(gca,'currentpoint');

        xdata = get(ruler.hLine,'XData');
        ydata = get(ruler.hLine,'YData');

        % Check the line orientation 
        switch lorient
            case 0
                set(ruler.hLine,'XData', [xdata(1) pos2(1,1)], 'YData', [ydata(1) pos2(1,2)]);
                set(ruler.hEnds(2), 'XData', pos2(1,1), 'YData', pos2(1,2));
            case 1
                set(ruler.hLine,'XData', [xdata(1) pos2(1,1)], 'YData', [ydata(1) ydata(1)]);
                set(ruler.hEnds(2), 'XData', pos2(1,1), 'YData', ydata(1));
            case 2
                set(ruler.hLine,'XData', [xdata(1) xdata(1)], 'YData', [ydata(1) pos2(1,2)]);                        
                set(ruler.hEnds(2), 'XData', xdata(1), 'YData', pos2(1,2));
        end
        drawnow;
        %% Update the info box:
        % Compute the time difference:
        [sxdata, six] = sort(xdata);
        dt = diff(sxdata);
%         if timeUnits     % i.e., if the x axis is in date format,
%             dtvec = datevec(dt);    % convert dt into seconds.
%             dt = dtvec(4:6)*[3600; 60; 1]; % dt in seconds.
%         end

        % Distance:
        ds = diff(ydata(six)); % [m]

        % Speed:
        v = ds/dt; % [m/s]

        set(ruler.info, ...
            'String', { ['dx:  ' num2str(dt,'%10.4f')],...
                        ['dy:  ', num2str(ds)], ...
                        ['dy/dx:  ', num2str(v)], ...
                        ['dx/dy:  ', num2str(1/v)], ...
                       });
    end

    %% Window button up callback
    function ruler_mbucb(hco,~)
    % Ruler mouse button up callback.

        % Clear the mouse events handlers:
        set(gcf,'WindowButtonDownFcn',  '');
        set(gcf,'WindowButtonMotionFcn','');
        set(gcf,'WindowButtonUpFcn',    '');

        % Get the handle of the ruler line:
        hLine = findobj(gcf,'Tag','ruler.line');
        ruler = get(hLine,'UserData');

        % Restore the old pointer:
        set(gcf,'Pointer',ruler.figurePointer);

        % Enable the cross-section plot button:
        hxPlotBtn = findall(hco,'Tag','xPlotBtn'); 
        set(hxPlotBtn, 'Enable', 'on');
        % Generate random figure number for the cross-section line:
        xplotFigure = randi(1e6,1);
        
        % Restore the previous figure hold status:
        if (~ruler.hold_status), hold off; end

        % Restore the mouse event handlers:
        set(gcf,'WindowButtonMotionFcn',ruler.fun_motion);
        set(gcf,'WindowButtonUpFcn',    ruler.fun_up);
        set(gcf,'WindowButtonDownFcn',  ruler.fun_down);
        
        % Free line orientation:
        lorient = 0;
    end

    %% Ruler ends: button down callback
    function rulerEnds_bdcb(src,~)
        ruler.endIx = find(ruler.hEnds == src);
        ruler.lineXdata = get(ruler.hLine, 'xdata');
        ruler.lineYdata = get(ruler.hLine, 'ydata');
        set(gcf,'WindowButtonMotionFcn', @rulerEnds_wbmcb);
        set(gcf,'WindowButtonUpFcn', @rulerLine_wbucb);
    end

    %% Ruler ends: window button motion callback
    function rulerEnds_wbmcb(~,~)
        cpos = get(gca,'CurrentPoint');
        set(ruler.hEnds(ruler.endIx), 'xdata', cpos(1,1), 'ydata', cpos(1,2));
        ruler.lineXdata(ruler.endIx) = cpos(1,1);
        ruler.lineYdata(ruler.endIx) = cpos(1,2);
        set(ruler.hLine, 'xdata', ruler.lineXdata, 'ydata', ruler.lineYdata);
        
        %% Update the info box:
        % Compute the time difference:
        [sxdata, six] = sort(ruler.lineXdata);
        dt = diff(sxdata);

        % Distance:
        ds = diff(ruler.lineYdata(six)); % [m]

        % Speed:
        v = ds/dt; % [m/s]

        set(ruler.info, ...
            'String', { ['dx:  ' num2str(dt,'%10.4f')],...
                        ['dy:  ', num2str(ds)], ...
                        ['dy/dx:  ', num2str(v)], ...
                        ['dx/dy:  ', num2str(1/v)], ...
                       });

    end

    %% Line shifting: line button down function
    function rulerLine_bdcb(~,~)
        cpos = get(gca,'CurrentPoint');
        ruler.p0 = cpos(1,1:2)'; % store the current point.
        ruler.lineXdata = get(ruler.hLine, 'xdata');
        ruler.lineYdata = get(ruler.hLine, 'ydata');
        ruler.endsXdata = get(ruler.hEnds, 'xdata');
        ruler.endsYdata = get(ruler.hEnds, 'ydata');
        set(gcf,'WindowButtonMotionFcn', @rulerLine_wbmcb);
        set(gcf,'WindowButtonUpFcn',     @rulerLine_wbucb);
    end
    
    %% Line moving: window button motion callback
    function rulerLine_wbmcb(~,~)
        cpos = get(gca, 'CurrentPoint');
        cpos = cpos(1,1:2)';
        shiftVector = cpos - ruler.p0;
        rulerLine_xdata = ruler.lineXdata + shiftVector(1);
        rulerLine_ydata = ruler.lineYdata + shiftVector(2);
        rulerEnds_xdata = [ruler.endsXdata{:}] + shiftVector(1);
        rulerEnds_ydata = [ruler.endsYdata{:}] + shiftVector(2);
        set(ruler.hLine, 'xdata', rulerLine_xdata, 'ydata', rulerLine_ydata);
        set(ruler.hEnds(1), 'xdata', rulerEnds_xdata(1), 'ydata', rulerEnds_ydata(1));
        set(ruler.hEnds(2), 'xdata', rulerEnds_xdata(2), 'ydata', rulerEnds_ydata(2));
    end

    %% Line moving: button up callback
    function rulerLine_wbucb(~,~)
        % Restore the button up and motion callbacks:
        set(gcf,'WindowButtonMotionFcn', ruler.fun_motion);
        set(gcf,'WindowButtonUpFcn',     ruler.fun_up);
        
        % Plot and process cross-section line:
        if xplotOn
            xline = rulerCrossSectionPlot();
            if ~isempty(xlineFcn)
                xlineFcn(xline, xlineFcnFigure);
            end
        end
    end        
    %% Plot cross-section line
    function rulerCrossSectionPlotOn(~,~)
        xplotOn = 1;
        % Create figure window:
        cfPos = get(gcf, 'Position');   % current figure position.
        nfPos = cfPos.*[1 1 1 .5];
        figure(xplotFigure);
        set(gcf, 'Name','Cross Section Plot', 'Position', nfPos);
        % Plot cross-section line:
        xline = rulerCrossSectionPlot();
        
        % If x-line processing function specified:
        % generare figure number to show the pocessed result.
        if ~isempty(xlineFcn)
            xlineFcnFigure = randi(1e6,1);
            xlineFcn(xline, xlineFcnFigure);
        end
    end

    function rulerCrossSectionPlotOff(~,~)
        xplotOn = 0;
    end

    function xline = rulerCrossSectionPlot()
        %% Get the line points:
        lobj = get(ruler.hLine); % line object.
        p0 = [lobj.XData(1); lobj.YData(1)];
        p1 = [lobj.XData(2); lobj.YData(2)];
        t = linspace(0,1,xlineNPoints);
        pt = p0*(1-t) + p1*t;

        %% Get the image values along the line:
        aobj = get(lobj.Parent); % axes object.
        himg = findobj(aobj.Children, 'type', 'image'); % handle to the image.
        img = get(himg); % image object.

        xx = zeros(size(t)); % the cross-section values.
        dXData = diff(img.XData(1:2));
        dYData = diff(img.YData(1:2));
        
        x_ix = floor( (pt(1,:)-img.XData(1))/dXData ) + 1;
        y_ix = floor( (pt(2,:)-img.YData(1))/dYData ) + 1;
        xx = img.CData(sub2ind(size(img.CData),y_ix,x_ix));
               
        xline = [pt' xx'];
        % Export the cross-section line to the base workspace:
        if ~isempty(xlineVarName)
            assignin('base', xlineVarName, xline); % [time, location, value].
        end
        
        %% Display the cross-section plot in a separate figure:
        figure(xplotFigure); clf;
        hax1 = gca;

    %     plot(t, cross); % The easiest way to plot data, regardless line orientation.
                          % However, difficult to put correct labels on the time and
                          % distance axis. 

        % Line orientation check:
        dsdt = pt(:,1)-pt(:,end);
        if abs(dsdt(2)) < 1e-6
            lorient = 1;
        elseif abs(dsdt(1)) < 1e-6
            lorient = 2;
        end

        % Plot cross section according to the line orientation:
        switch lorient
            case 0  % free line.
                plot(pt(2,:), xx); % distance on the x-axis.
                % Revert the x-axis if distance is decreasing:
                if prod(dsdt)<0, set(gca,'XDir','rev'); end
                xlabel(ydimLabel);
                axis tight
                set(hax1,'Box','off');

                % Create an additional top axis for time display:
                hax1_pos = get(hax1,'Position');
                hax2 = axes('Position',hax1_pos,'XAxisLocation','top','YAxisLocation','right','Color','None');
                line(pt(1,:),xx, 'Parent',hax2, 'color','r');
                
                xlabel(xdimLabel);
                
            case 1 % - horizontal line.
                plot(pt(1,:), xx); % plot vs x-axis.
                xlabel(xdimLabel);
                title([ydimLabel ' : ' num2str(pt(2,1))]);
            case 2 % vertical line.
                plot(pt(2,:), xx); % plot vs y-axis.
                xlabel(ydimLabel);
                title([xdimLabel ' : ' num2str(pt(1,1))]);
        end
        axis tight; grid on;
    end

    %% Keyboard events callbacks
    function rulerKeyPress(~,evt)
    % Handler for the keyboard key press event.
        if strcmpi(evt.Modifier,'control')
            lorient = 1;         
        elseif strcmpi(evt.Modifier,'alt')
            lorient = 2;
        end
    end

    function rulerKeyRelease(~,~)
    % Handler for the keyboard key release event.
        lorient = 0;
    end

    %% Ruler properties button callback
    function rulerPropDlg(~,~)
        prompt = { 
                   'Line style',... 
                   'Ends points style',... 
                   'Cross-line length [points]',... 
                   'Var name to export the x-line',...
                   'Fcn name to process the x-line data'
                  };
        defs = { 
                 lineStyle,... 
                 lineEndStyle,...             
                 num2str(xlineNPoints),... 
                 xlineVarName,...
                 func2str(xlineFcn)
                };
        ansr = inputdlg(prompt, 'Ruler properties', 1, defs);
        if ~isempty(ansr)
            lineStyle    = ansr{1};
            lineEndStyle = ansr{2};            
            xlineNPoints = str2double(ansr{3});
            xlineVarName = ansr{4};
            if ~isempty(ansr{5})
                xlineFcn = str2func(ansr{5});
            else
                xlineFcn = [];
            end
        end
    end
end