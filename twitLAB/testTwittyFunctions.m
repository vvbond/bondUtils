%% Tests of twitty functions
%% tw.plotStatusLocation
clear
tw = twitty;
tw.outFcn = @ tw.statsTwitterUsageByLanguage;
tw.sampleSize = 10000;
tw.batchSize = 50;

S = tw.sampleStatuses