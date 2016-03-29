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
expFile = fullfile(experimentDir, name, ext);

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
experi.creator = struct; % Here the blocks with events will be added
experi.experiment = struct; % Here the generated experiment will be stored (when exp is run)


%% Save
save(expFile, 'experi');
end

