%% Merge multiple GPS structures into one
%% Load multiple structures in a structure array:
clear structArray
fdir = '/ApolloData/vbond/TTCI/FW/2015-02/GPS/203 4Feb15';
fnames = {'203 6Feb15 0820.nmea.mat', '203 6Feb15 1030.nmea.mat', '203 6Feb15 1330.nmea.mat'};
for k=1:length(fnames)
    load(fullfile(fdir, fnames{k}));
    structArray(k) = nmea;
end
%% Merge structures:
fieldNames = fieldnames(structArray);
for ii=1:length(fieldNames)
    newStruct.(fieldNames{ii}) = vertcat(sctructArray(:).(fieldNames{ii}) );
end