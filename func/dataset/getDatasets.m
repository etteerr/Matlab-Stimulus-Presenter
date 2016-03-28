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
for i=1:length(dirs)
    dirn = dirs(i);
    if dirn.isdir && ~strcmp(dirn.name,'.') && ~strcmp(dirn.name,'..')
        if exist(fullfile(dataFolder, dirn.name, datasetInfofile),'file')
            iter = iter + 1;
            datasets{iter} = dirn.name;
        end
    end
end

end

