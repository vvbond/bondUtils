classdef PU < handle
% Processing unit.
    properties
        src
        sink
        init_fcn
        process_fcn
        hl_eos
        hl_ready
        tmr
    end
    
    events
        Ready
    end
    
    methods
        %% {Con,De}structor
        function pu = PU(src, sink, process_fcn)
            pu.src = src;
            pu.sink = sink;
            
            if nargin == 3
                if isa(process_fcn, 'function_handle')
                    pu.process_fcn = process_fcn;
                else
                    error('The 3d argument must be a function handle.');
                end
            end
            
            % Timers:
            pu.tmr = timer;
%             pu.tmr.StartFcn = @pu.timer_start;
%             pu.tmr.StopFcn = @pu.timer_stop;
            pu.tmr.TimerFcn = @(src,evt) pu.process;            
            pu.tmr.Period = .001;
            pu.tmr.ExecutionMode = 'fixedSpacing';
            
            pu.init;
            
            if any(strcmpi(events(pu.src), 'EndOfStream'))
                pu.hl_eos = event.listener(pu.src, 'EndOfStream', @(src,evt) pu.finish);
            end
        end
        
        function delete(pu)
            delete(pu.hl_ready);
            delete(pu.hl_eos);
            delete(pu.tmr);
        end
        
        %% Initialisation
        function init(pu)
        % Initialise the unit, source and sink.
            
            % Initialise source:
            if any(strcmpi(methods(pu.src), 'init'))
                pu.src.init;
            end
            if any(strcmpi(methods(pu.src), 'open'))
                pu.src.open;
            end

            % Initialise sink:
            if any(strcmpi(methods(pu.sink), 'init'))
                pu.sink.init;
            end
            if any(strcmpi(methods(pu.sink), 'open'))
                pu.sink.open;
            end

            
            % Type-specific sink handling:
            if isa(pu.sink, 'ViewPort') && ishandle(pu.sink.playBtn)
                set(pu.sink.playBtn, 'OnCallback',  @(src,evt) pu.start,...
                                     'OffCallback', @(src,evt) pu.stop,...
                                     'Enable', 'on');
            end
        end
        
        %% Connect to another unit
        function connect(pu, eventSource)
            pu.hl_ready = event.listener(eventSource, 'Ready', @(src,evt) pu.process);
        end
        
        %% Process
        function process(pu)
            Din = pu.src.read;
            if ~isempty(Din)
                if ~isempty(pu.process_fcn)
                    Dout = pu.process_fcn(Din);
                else
                    Dout = Din;
                end
                pu.sink.write(Dout);
            end
            notify(pu, 'Ready');
        end
        
        function finish(pu)
            pu.stop;
            fprintf('[%s] End of stream.\n', datestr(now));
            if isa(pu.sink, 'ViewPort') && ishandle(pu.sink.playBtn)
                pu.sink.playBtn.Enable = 'off';
            end            
        end
        
        %% Timer
        function start(pu)
        % Start timer.
            if strcmpi(pu.tmr.Running, 'on'), return; end
            start(pu.tmr);
            if isa(pu.sink, 'ViewPort') && ishandle(pu.sink.playBtn)
                pu.sink.playBtn.State = 'on';
            end
        end
        
        function stop(pu)
        % Stop timer.
            stop(pu.tmr);
            if isa(pu.sink, 'ViewPort') && ishandle(pu.sink.playBtn)
                pu.sink.playBtn.State = 'off';
            end
        end
        
    end
end