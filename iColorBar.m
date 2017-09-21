classdef iColorBar < handle
% Interactive colorbar.    
%
% Usage: iColorBar
% 
% Use the mouse to adjust the upper limit of the color axis;
% alternatively hold the 'Alt' key to alter caxis' lower limit,
% or hold the 'Shift' key to shift both lower and upper limits.
%
% Example:
%  figure, imagesc(peaks(100)); iColorBar

    properties(Hidden)
        hbtn
        htbar
        hcb
        hax
        hfig
        caxPos
        fpos
        caxLims
        
        mode = 0        % 0 (default)   - adjust the upper bound of caxis;
                        % 1 (Alt key)   - alter the lower limit of caxis;
                        % 2 (Shift key) - shift both lower and upper limits.
        
        old_wbmcb
        old_wbucb
        old_fkpcb
        old_fkrcb
    end
    
    %% {Con,De}structor
    methods
        function icb = iColorBar()
            icb.hfig = gcf;
            icb.hax = gca;
            
            % Add toggle button:          
            icon_fname = 'icolorbarIcon.mat';
            icolorbarIcon = load(fullfile(fileparts(mfilename('fullpath')),'icons', icon_fname));
            
            % Look if the button is already there:
            icb.htbar = findall(icb.hfig, 'Tag', 'FigureToolBar');
            icbBtn = findall(icb.htbar, 'Tag', 'icolorbar_btn');
            if ~isempty(icbBtn)
                icb.hbtn = icbBtn;
                set(icb.hbtn, 'onCallback',  @(src, evt) icb.icbON(src, evt),...
                              'offCallback', @(src, evt) icb.icbOFF(src,evt),...
                              'CData', icolorbarIcon.cdata,...
                              'State', 'off',...
                              'UserData', []);
            else
                icb.hbtn =  uitoggletool(icb.htbar(1),  'CData', icolorbarIcon.cdata, ...
                                                        'onCallback',  @(src,evt) icb.icbON(src,evt),...
                                                        'offCallback', @(src,evt) icb.icbOFF(src,evt),...
                                                        'Separator', 'off',...
                                                        'tooltipString', 'Insert interactive colorbar',...
                                                        'Tag', 'icolorbar_btn');
                % Re-order buttons:
                hBtns = findall(icb.htbar(1));
                dumIx = zeros(length(hBtns), 1);
                for ii=1:length(hBtns), dumIx(ii) = strcmpi(hBtns(ii).Tag, 'Annotation.InsertColorBar'); end
                cbarIx = find(dumIx);
                set(icb.htbar, 'children', [hBtns(3:cbarIx-1); hBtns(2); hBtns(cbarIx:end)]);
            end            
        end
        
        function delete(icb)
        % Destructor.
        
            % Remove button:
            if ishandle(icb.hbtn), delete(icb.hbtn); end
                
            % Restore figure callbacks:
            if ishandle(icb.hfig)                
                set(icb.hfig, 'WindowButtonMotionFcn', icb.old_wbmcb, ...
                              'WindowButtonUpFcn',     icb.old_wbucb, ... 
                              'KeyPressFcn',           icb.old_fkpcb, ...
                              'KeyReleaseFcn',         icb.old_fkrcb );
            end
        end
    end
    
    %% ON/OFF
    methods
        function icbON(icb, ~, ~)
            
            % Creat colorbar:
            icb.hcb = colorbar;
            
            % Switch off interactive modes:
            icb.interactivesOff;
            
            % Setup interactions:
            set(icb.hcb,  'ButtonDownFcn', @(src,evt) bdcb(icb,src,evt));
        end
        
        function icbOFF(icb, ~, ~)
            
            % Remove colorbar:
            delete(icb.hcb);
            
            % Restore figure callbacks:
            if ishandle(icb.hfig)                
                set(icb.hfig, 'WindowButtonMotionFcn', icb.old_wbmcb, ...
                              'WindowButtonUpFcn',     icb.old_wbucb, ... 
                              'KeyPressFcn',           icb.old_fkpcb, ...
                              'KeyReleaseFcn',         icb.old_fkrcb );
            end
        end
    end
    
    %% Interactions
    methods
        function bdcb(icb, ~, ~)
            set(icb.hcb, 'units', 'pixels');
            icb.caxPos = get(icb.hcb, 'position');
            set(icb.hcb, 'units', 'normalized');                    
            icb.fpos = get(gcf, 'currentPoint')*[0; 1] - icb.caxPos(2); % y coordinate [px].
            icb.caxLims = caxis(icb.hax);
            
            % Store old interaction callbacks:
            icb.old_wbmcb  = get(gcf, 'WindowButtonMotionFcn');
            icb.old_wbucb  = get(gcf, 'WindowButtonUpFcn');
            icb.old_fkpcb  = get(gcf, 'KeyPressFcn');
            icb.old_fkrcb  = get(gcf, 'KeyReleaseFcn');
            
            % Set new interactions:
            set(icb.hfig, 'WindowButtonMotionFcn', @(src,evt) wbmcb(icb, src, evt),...
                          'WindowButtonUpFcn',     @(src,evt) wbucb(icb, src, evt));
            set(icb.hfig, 'KeyPressFcn',   @(src,evt) fkpcb(icb,src,evt), ...
                          'KeyReleaseFcn', @(src,evt) fkrcb(icb,src,evt) );                                  
        end
        
        function wbmcb(icb, ~, ~)
            fpos2 = (get(icb.hfig,'currentPoint')*[0;1] - icb.caxPos(2));
            switch icb.mode
                case 1  % alt: alter caxis lower limit.
                    caxNewMin = ( icb.caxLims(1)*(icb.caxPos(4)-icb.fpos) + icb.caxLims(2)*(icb.fpos - fpos2) )/(icb.caxPos(4)-fpos2);
                    caxLims1  = [caxNewMin icb.caxLims(2)]; % update color axis lower limit.
                case 2  % shift: shift caxis, no rescaling. 
                    delta = (icb.fpos - fpos2)/icb.caxPos(4)*diff(icb.caxLims);
                    caxLims1 = icb.caxLims + delta;
                otherwise % alter caxis upper limit.
                    caxNewMax =  icb.caxLims(1) + icb.fpos/fpos2*diff(icb.caxLims);
                    caxLims1  = [icb.caxLims(1) caxNewMax]; % update color axis upper limit. 
            end
            if caxLims1(2) > caxLims1(1)
                try
                    caxis(icb.hax, caxLims1);
                catch ME
                    warning('iColorBar: couln''t set color axis for the limits: [%5.2f %5.2f]\n %s', caxLims1, ME.message);
                end             
            end
        end
        
        function wbucb(icb, ~, ~)
            % Restore the old interaction callbacks:
            set(icb.hfig, 'WindowButtonMotionFcn', icb.old_wbmcb, ...
                          'WindowButtonUpFcn',     icb.old_wbucb );
        end
        
        function fkpcb(icb, ~, evt)
            if strcmpi(evt.Modifier, 'alt')
                icb.mode = 1;
            elseif strcmpi(evt.Modifier, 'shift')
                icb.mode = 2;
            end
        end
        
        function fkrcb(icb, ~, ~)
            icb.mode = 0;
        end
    end
    
    %% Misc
    methods
        function interactivesOff(icb)
            plotedit off, zoom off, pan off, rotate3d off, datacursormode off, brush off
        end
    end
end