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
function [ succes ] = createExperiment( name )
%createExperiment(name)
%   creates an experiment witht the name [name]
%   It checks thinks like:
%   - Valid name (longer than 2)
%   - Non-existing
%   - dont know yet...

%% Settings
experimentDir = 'Experiments';
ext = '.mat';
expFile = fullfile(experimentDir, [name ext]);

%% Checks
if length(name) < 3
    error('Name is too short (3 or more characters required)');
end

if experimentExists(name)
    error('Experiment with the name "%s" already exists',name);
end

%% Create new experiment file
experi = struct;

experi.name = name;
experi.datasetDep = {}; % No dataset dependencies yet
experi.eventDep = {}; % No event dependencies yet
experi.creator = {}; % Here the blocks with events will be added
experi.experiment = {}; % Here the generated experiment will be stored (when exp is run)


%% Save
save(expFile, 'experi');
end

