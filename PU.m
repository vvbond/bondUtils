classdef PU < handle
% Processing unit.
    properties
        src
        sink
        process_fcn
        hl
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
        end
        
        function delete(pu)
            delete(pu.hl);
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
%             if any(strcmpi(methods(pu.sink), 'init'))
%                 pu.sink.init;
%             end
            if isa(pu.sink, 'ViewPort') || isa(pu.sink, 'ViewPort1')
                if ishandle(pu.sink.playBtn)
                    set(pu.sink.playBtn, 'OnCallback',  @(src,evt) pu.start,...
                                         'OffCallback', @(src,evt) pu.stop);
                end
            end
        end
        
        %% Connect to another unit
        function connect(pu, eventSource)
            pu.hl = addlistener(eventSource, 'Ready', @(src,evt) pu.process);
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
                pu.sink.push(Dout);
            end
            notify(pu, 'Ready');
        end
        
        %% Timer
        function start(pu)
            start(pu.tmr);
        end
        
        function stop(pu)
            stop(pu.tmr);
        end
        
    end
end