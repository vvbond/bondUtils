%% Tips and tricks
%% 1. Console control
%% 1.1 Progess bar
%% 1.1.1 The principle
fprintf('progress: ..... 50%%\n'); fprintf(['\b\b\b\b\b. 60%%\n']);
%% 1.1.2 Implementation 1: progress bar
reverseStr = '';
someLargeNumber = 1e4;
for idx = 1 : someLargeNumber
 
   % Do some computation here...
 
   % Display the progress
   percentDone = 100 * idx / someLargeNumber;
   msg = sprintf('Percent done: %3.1f %%\n', percentDone);
   fprintf([reverseStr, msg]);
   reverseStr = repmat(sprintf('\b'), 1, length(msg));
end
%% 1.1.2 Implementation 2: blinking text
fprintf(['off\n']); for n=1:10, pause(0.5); fprintf(['\b\b\b\bon \n']); pause(0.5); fprintf(['\b\b\b\boff\n']); end
%% 1.3 Implementation 3: progress bar
fprintf('progress:  00%%\n'); for n=1:10, pause(1); fprintf(['\b\b\b\b\b. %d%%\n'],10*n); end