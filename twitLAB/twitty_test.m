%% Test twitty
%% Create twitty object
tw = twitty;

%% Test the examples section
%% Checkin search
disp('Checking search()');
try
    S = tw.search('matlab job');
    disp('OK');
catch exception
    disp('NOT OK');
end
% for ii=1:length(S.results)
%     disp(S.results{ii}.text);
% end
%% Checking updateStatus()
disp('Checking updateStatus()');
try
    S = tw.updateStatus('Using twitty.m for twitting from MATLAB.');
    disp('OK');
catch exception
    disp('NOT OK!')
end

%% Checking sampleStatuses() [ previously publicTimeline() ]
disp('Checking sampleStatuses()');
try
    S = tw.sampleStatuses();
    disp('OK');
catch exception
    disp('NOT OK!')
end

%% Checking userTimeline
disp('Checking userTimeline()');
try 
    S = tw.userTimeline('screen_name','matlab');
    disp('OK');
%     for ii=1:length(S), disp(S{ii}.text); end
catch exception
    disp('NOT OK!');
end
%% Checking trendsDaily()
disp('Checking trendsDaily()');
try 
    S = tw.trendsDaily(datestr(now-1,'yyyy-mm-dd'));
    disp('OK');
catch exception
    disp('NOT OK');
end