%     Copyright (C) 2016  Erwin Diepgrond
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
    fullPath = fullfile(cd,dataFolder,name,file);
    datasetInfo.fullPath{i} = fullPath;
    if ~exist(fullPath, 'file')
        warning('Missing %s at %s', ...
            file, fullPath);
    end
end

end

