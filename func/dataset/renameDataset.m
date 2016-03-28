function [ succes ] = renameDataset( name, newname )
%RENAMEDATASET Summary of this function goes here
%   Detailed explanation goes here
succes = 0;
%% Settings
dataFolder = 'Data';
datasetInfofile = 'datainfo.mat';

%% Checks
if datasetExists(newname)
    error('Dataset %s exists',name);
end

if ~datasetExists(name)
    error('Dataset %s does not exists',name);
end


%% Get data
folder = fullfile(dataFolder,name);

%% Ren dir
newFolder = fullfile(dataFolder,newname);
[status,message] = movefile(folder, newFolder);
if ~status
    warning('Renaming failed: %s',message);
else
    succes = 1;
end

%% Rename name in datainfo
file = fullfile(newFolder,datasetInfofile);
load(file);
datasetInfo.name = newname;
save(file,'datasetInfo');
end

