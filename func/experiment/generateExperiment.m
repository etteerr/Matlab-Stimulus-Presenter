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
function [ runtimeExperiment, eventNames ] = generateExperiment( generatorPackage )
%GENERATEEXPERIMENT Summary of this function goes here
%   Detailed explanation goes here
%% SEttings
datadir = 'Data';
%% Unpack
experiment = generatorPackage.expData;
runmode = generatorPackage.runMode;
startMessage = generatorPackage.startMessage;
startDelay = generatorPackage.startDelay;
interTDelay = generatorPackage.interTDelay;

%% Reassign
rte = struct;
creator = experiment.creator; % The creator events
name = experiment.name;
%% Set name and creation date and time
rte.name = name;
rte.date = date();
c = clock();
rte.time = sprintf('%i:%i', c(4), c(5));
%% Set experiment info
rte.nRepeats = 1;
rte.nTrials = 0; %Set it later
rte.startDelay = startDelay; %make it variable
rte.interTrialDelay = interTDelay; %make it variable
rte.runMode = runmode; %1 = preload; 0 = no preload
rte.preMessage = startMessage;%'Welcome to the experiment! Press anykey to start'; % variable it must be!

%% Datasets
datasetNames = {};
datasets = {};
datasetIter = 0;
eventNamesIter = 0;
eventNames = {};
for i=1:length(creator) %For block in blocks
    block = creator{i}; %block struct
    events = block.events; %Êvent cell
    for j=1:length(events)
        event = events{j};
        if sum(strcmp(event.name, eventNames)) == 0
            % Also create a list of event names that are present
            eventNamesIter = eventNamesIter + 1;
            eventNames{eventNamesIter} = event.name;
        end
        if isfield(event,'dataset')
            datasetname = event.dataset;
            if sum(strcmp(datasetname,datasetNames)) == 0
                datasetIter = datasetIter + 1;
                datasetInfo = getDataset(datasetname);
                datasetFiles = {};
                for k=1:length(datasetInfo.files)
                    file = datasetInfo.files{k};
                    file = fullfile(cd,datadir,datasetname,file);%Change to using datasetInfo.fullPath
                    datasetFiles{k} = file;
                end
                datasets{datasetIter} = datasetFiles;
                datasetNames{datasetIter} = datasetname;
            end
        end
    end
end

if ~isempty(datasets)
    % Get the corresponding files for each dataset used
    datasets = containers.Map(datasetNames,datasets);
    % get the iter for non-random data selection without putback
    datasetIters = containers.Map(datasetNames,zeros(1,length(datasetNames)));
end

%% Create events
% eventStruct.dataset = dataset;
% eventStruct.randomData = random;
% eventStruct.putBack = putBack;
rte.trials = {}; %Blocks

%rte.trials(1).events = {};
for i=1:length(creator) %For block in blocks
    block = creator{i}; %block struct
    events = block.events; %Êvent cell
    trial = {};
    tmp = cell(1,length(events));
%     for j=1:length(events)
    eventCounter = 0;
    while eventCounter < length(events)
         eventCounter = eventCounter + 1;
         j = eventCounter;
        event = events{j};
        %Event flow control options
%         out.generatorRepeat = str2double(data(2).Answer);
%         out.generatorNBack = floor(str2double(data(1).Answer));
        if isfield(event, 'generatorRepeat') && isfield(event, 'generatorNBack')
            if isempty(tmp{j})
                tmp{j} = 1;
                eventCounter = eventCounter - 1 - event.generatorNBack;
            elseif tmp{j} < event.generatorRepeat
                tmp{j} = tmp{j} + 1;
                eventCounter = eventCounter - 1 - event.generatorNBack;
            end
        end
            
        
        %Get random data from dataset if random is needed
        if isfield(event, 'dataset') && ~isempty(datasets)
            dataset = datasets(event.dataset);
            index = 0;
            if isempty(dataset)
                error('Not enough files in the dataset %s', event.dataset);
            end
            if event.randomData
                index = randi(length(dataset));
            else % it start at 0, we add one every time.
                datasetIters(event.dataset) = mod(datasetIters(event.dataset) + 1,length(dataset));
                if (datasetIters(event.dataset)==0)
                    datasetIters(event.dataset)=length(dataset);
                end
                index = datasetIters(event.dataset);
            end
            if length(dataset) < index
                error('Not enough files in the dataset %s', event.dataset);
            end
            events{j}.data = dataset{index};
            if ~event.putBack
                dataset(index) = [];
                datasets(event.dataset) = dataset;
            end
        end
        events{j}.blockname = block.name;
        trial = [trial events(j)];
    end
    rte.trials{i} = trial;
end
rte.nTrials = length(rte.trials);
runtimeExperiment = rte;
end

