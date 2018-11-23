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

