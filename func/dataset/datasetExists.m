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

