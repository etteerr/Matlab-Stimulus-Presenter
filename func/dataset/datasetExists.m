function [ datasExists ] = datasetExists( name )
%DATASETEXISTS returns true if it exists

%% Settings
dataFolder = 'Data';
datasetInfofile = 'datainfo.mat';
%% input checks
if ~ischar(name)
    error('Name must be a string!');
end

%% Paths
datasetPath = fullfile(dataFolder, name);
datasetInfoPath = fullfile(dataFolder,name,datasetInfofile);

%% Check
if exist(datasetPath,'dir') == 7
    if exist(datasetInfoPath,'file')==2
        datasExists = 1;
        return
    end
end
datasExists = 0;
end

