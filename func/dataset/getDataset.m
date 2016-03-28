function [ datasetInfo ] = getDataset( name )
%GETDATASET returns the datasetInfo with fullpaths
%   Creates a fullpathed version of the datasetInfo

%% Settings
dataFolder = 'Data';
datasetInfofile = 'datainfo.mat';

%% check
if ~datasetExists(name)
    error('Dataset %s does not exist', name);
end

%% Get
infoFile = fullfile(dataFolder,name, datasetInfofile);

load(infoFile);

%% Add fullPaths
datasetInfo.fullPath = {};
for i=1:datasetInfo.nFiles
    file = datasetInfo.files{i};
    fullPath = fullfile(cd,dataFolder,file);
    datasetInfo.fullPath{i} = fullPath;
    if ~exist(fullpath, 'file')
        error(['Something went wrong when creating fullpaths...\n' ...
            'File %s does not exist in fullpath:\n%s'], ...
            file, fullpath);
    end
end

end

