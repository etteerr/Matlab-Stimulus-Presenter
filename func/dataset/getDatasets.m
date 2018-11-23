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

