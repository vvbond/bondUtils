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
            icb.hcb = colorbar;
                       
            % Setup interactions:
            set(icb.hcb,  'ButtonDownFcn', @(src,evt) bdcb(icb,src,evt));
            set(icb.hfig, 'KeyPressFcn',   @(src,evt) fkpcb(icb,src,evt), ...
                          'KeyReleaseFcn', @(src,evt) fkrcb(icb,src,evt) );
        end
        
        function delete(icb)
        % Destructor.
        
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

            set(icb.hfig, 'WindowButtonMotionFcn', @(src,evt) wbmcb(icb, src, evt),...
                          'WindowButtonUpFcn',     @(src,evt) wbucb(icb, src, evt));
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
            caxis(icb.hax, caxLims1);
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
end