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
function [ succes, path, fullpath ] = createDataset( name, files, type , settings)
%CREATEDATASET Creates a folder representing the dataset
%   Type specifies the filetype
%   
%   All files into a directory
%   File indexing all files and dataset behavior
%   saves file ORDER and settings to file
succes = 0;
%% Settings
dataFolder = 'Data';
datasetInfofile = 'datainfo.mat';

%% Input checks
if datasetExists(name)
    error('Dataset %s exists',name);
end

if ~iscell(files)
    error('Invalid input: files must be a cell!');
end

if length(name) < 3
    answ = inputdlg('Name too short, please use a name > 2','createDataset');
    name = answ{1};
    if length(name) < 3
        error('Invalid input: Name too short')
    end
end

if ~isstruct(settings)
    error('Invalid input: Settings must be a struct');
end

%% folder checks
if ~(exist(dataFolder,'dir')==7)
    error('%s does not exist or is not a directory!',dataFolder);
end

if exist(fullfile(dataFolder,name),'dir')==7
    warning('folder %s already exists',fullfile(dataFolder,name))
end

%% Create dataset
if ~(exist(fullfile(dataFolder,name),'dir')==7)
    [status, message ] = mkdir(fullfile(dataFolder,name));
    if status == 0
        error('Create dataset: Something went wrong while creating the folder!\n%s', message);
    end
end

%% Copy files
bh = waitbar(0,'Creating dataset...');
filenames = {};
fin = 0;
nfiles = length(files);
if nfiles == 0
    warning('Empty dataset');
end
for fi=1:nfiles;
    waitbar(fi/nfiles,'Creating dataset...');
    file = files{fi};
    [~,name,ext] = fileparts(file);
    dest = fullfile(cd, dataFolder, name, [name ext]);
    [succes, message] = copyfile(file, dest);
    if ~succes
        warining('Filecopy for %s failed:\n%s',file,message);
    else
        fin = fin + 1;
        filenames{fin} = [name ext];
    end
    
end
    


%% Create info file
waitbar(1,bh,'Creating dataset info...');
datasetInfo = struct;
datasetInfo.settings = settings;
datasetInfo.nFiles = length(filenames);
datasetInfo.name = name;
datasetInfo.files = filenames;
datasetInfo.createdDate = datetime('today');
datasetInfo.filetype = type;

%save
save(fullfile(dataFolder,name,datasetInfofile), 'datasetInfo');

%% Return values
path = fullfile(dataFolder,datasetInfofile);
fullpath = fullfile(cd,dataFolder,datasetInfofile);
succes = 1;
delete(bh);
% Dont do anything with path
end

