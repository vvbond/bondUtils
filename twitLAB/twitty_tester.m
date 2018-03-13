%% Test twitty's functionality using a test account, twitty_tester

% Load twitty_tester credentials:
load('twitty_tester.mat');
% Create twitty object:
tw = twitty(twitty_tester_credentials);
% Twit somethting:
S = tw.updateStatus('Hi! It is a test twit from matlab.')