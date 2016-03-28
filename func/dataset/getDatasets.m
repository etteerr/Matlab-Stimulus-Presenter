function [ datasets ] = getDatasets()
%GETDATASETS returns a cell containing the names of all existing datasets.
%   Detailed explanation goes here

%% Settings
dataFolder = 'Data';
datasetInfofile = 'datainfo.mat';

%% Get all directors in dataFolder
dirs = dir(dataFolder);

%% Check which have the datasetInfofile
datasets = {};
iter = 0;
for i=length(dirs)
    dir = dirs(i);
    if dir.isdir && ~strcmp(dir.name,'.') && ~strcmp(dir.name,'..')
        if exist(fullfile(dataFolder, dir.name, datasetInfofile),'dir') == 7
            iter = iter + 1;
            datasets{iter} = dir.name;
        end
    end
end

end

