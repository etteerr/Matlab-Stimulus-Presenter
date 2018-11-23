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
function [ succes ] = delDataset( name )
%DELDATASET Summary of this function goes here
%   Detailed explanation goes here
succes = 0;
%% Settings
dataFolder = 'Data';
datasetInfofile = 'datainfo.mat';

%% Does it exist?
if ~datasetExists(name)
    warning('Dataset %s does not exist', name);
    succes = 1;
    return
end

%% Delete datasetInfofile
prevState = recycle('on');
delete(fullfile(dataFolder, name, datasetInfofile));

%% Do we want the files gone as well?
answer = questdlg('Do you want to delete the actual files as well? (only the ones In the Data folder, not anywhere else)'...
    , 'Deleting dataset files', 'yes', 'no', 'maybe','yes');
if strcmp(answer,'yes')
    p = fullfile(dataFolder,name);
    waitfor(warndlg(sprintf('This folder and all its content will be deleted: %s', p)));
    [status, message] = rmdir(p,'s');
    if ~status
        recycle(prevState);
        errordlg(sprintf('Folder was not deleted: %s', message));
        return
    end
end
if strcmp(answer, 'maybe')
    msgbox('That isnt a very usefull answer now, is it? Ill leave em in the folder...','Ugh...');
    return
end

%% Reset state
recycle(prevState);
succes = 1;
end

