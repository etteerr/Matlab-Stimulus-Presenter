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
function [ succes, completeSucces ] = updateDataset(varargin)
%% updateDataset(name,[ addFiles, removeFiles, purge, Order])
% name(str): Name of the dataset (required & must exist)
% addFiles(cell): a list of fullpath files to add
% removeFiles(cell): a list of filenames to remove
% purge(logic): Removes missing files from the list
% purge happens after adding and removing files. This ensures database
% intregrity .
% the order of the files in the dataset. Given: {'filename.ext',...}
% Any ingiven file from order is placed on the bottom.
% Order: removeFiles -> addFiles -> purge -> order

%% Settings
datadir = 'Data';
datasetInfofile = 'datainfo.mat';

%% Defaults
addFiles = {};
removeFiles = {};
purge = 0;
order = {};
succes = 0;
completeSucces = 1;

%% Checks
if ~(sum(nargin==[1,2,3,4,5])==1)
    error('Invalid usage. Please type: help updateDataset');
end

if nargin>=1
    name = varargin{1};
    try
        if ~datasetExists(name)
            error('Dataset %s non-existent',name);
        end
    catch e
        error('Invalid input for name:\n%s',e.message);
    end
end

if nargin >=2
    addFiles = varargin{2};
    if ~iscell(addFiles)
        error('Invalid input: addFiles must be a cell');
    end
end

if nargin >=3
    removeFiles = varargin{3};
    if ~iscell(removeFiles)
        error('Invalid input: removeFiles must be a cell');
    end
end

if nargin >=4
    purge = varargin{4};
    if ~islogical(purge) && ~isnumeric(purge)
        error('Invalid input: update must be a logical or numeric');
    end
end

if nargin ==5
    order = varargin{5};
    if ~iscell(order)
        error('Invalid input: order must be a cell');
    end
end
%% Paths
datasetPath = fullfile(datadir,name);
datasetInfoPath = fullfile(datadir,name, datasetInfofile);
datasetInfo = getDataset(name);

%% datasetInfo checks
if ~strcmp(datasetInfo.name,name)
    warning('Dataset name and folder name dont match...\ndataset name getting updated...');
    datasetInfo.name = name;
end

%% removeFiles
if ~isempty(removeFiles)
    for fi=1:length(removeFiles)
        file = removeFiles{fi};
        idx = find(strcmp(datasetInfo.files,file));
        if ~isempty(idx)
            datasetInfo.files(idx) = [];
            try
                delete(fullfile(datasetPath,file));
            catch e
                warning('Error while deleting file %s:\n%s', file, e.message);
                completeSucces = 0;
            end
        else
            warining('Removing file failed: file %s not found', file);
            completeSucces = 0;
        end
    end
end

%% Addfiles
if ~isempty(addFiles)
    addedFiles = {};
    hWaitbar = waitbar(0,'Adding files...');
    index = 0;
    for fi=1:length(addFiles)
        [~, filename, ext] = fileparts(addFiles{fi});
        waitbar(fi/length(addFiles),hWaitbar, sprintf('Adding %s...',filename));
        try
            [status, message] = copyfile(addFiles{fi}, fullfile(datasetPath,[filename, ext]));
            if status
                index = index + 1;
                addedFiles{index} = [filename, ext];
            else
                error('Copy file failed: %s', message);
            end
        catch e
            warning('Adding file "%s" failed:\n%s', filename, e.message);
            completeSucces = 0;
        end
    end
    waitbar(1,hWaitbar,'Updating database info...');
    [x, ~] = size(addedFiles);
    if x > 1
        datasetInfo.files = [datasetInfo.files; addedFiles];
    else
        datasetInfo.files = [datasetInfo.files; addedFiles'];
    end
    delete(hWaitbar);
end

%% update
if purge
    idxes = [];
    for fi = 1:length(datasetInfo.files)
        file = datasetInfo.files{fi};
        fPath = fullfile(datasetPath, file);
        if ~exist(fPath, 'file')
            fprintf('Purge database: %s is missing. Purging...\n', file);
            idxes = [idxes fi];
        end
    end
    datasetInfo.files(idxes) = [];
end

%% order
if ~isempty(order)
    newOrder = {};
    for i=1:length(order)
        file = order{i};
        indx = find(strcmp(file, datasetInfo.files));
        if ~isempty(indx)
            newOrder = [ newOrder; datasetInfo.files(indx)];
            datasetInfo.files(indx) = [];
        end
    end
    newOrder = [newOrder; datasetInfo.files];
    datasetInfo.files = newOrder;
end

%% Remove duplicates
new = {};
for i=1:length(datasetInfo.files)
    thing = datasetInfo.files{i};
    idx = find(strcmp(thing,new));
    if isempty(idx)
        new = [new;{thing}];
    end
end
datasetInfo.files = new;


%% Finish
datasetInfo.nFiles = length(datasetInfo.files);
save(datasetInfoPath,'datasetInfo');
succes = 1;