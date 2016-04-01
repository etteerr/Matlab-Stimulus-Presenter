function [ succes ] = delExperiment( name )
%DELEXPERIMENT Summary of this function goes here
%   Detailed explanation goes here
succes = 0;
%% Settings
experimentDir = 'Experiments';
ext = '.mat';
expFile = fullfile(experimentDir, [name ext]);

%% check
[exists, ~, path] = experimentExists(name);
if ~exists
    warning('Experiment (%s) does not exist', name);
end

%% Del
answ = questdlg(sprintf('Are you sure you want to delete %s?', name),'Confirm', 'Yes', 'No', 'No');

if strcmp(answ,'Yes')
    try
        delete(path);
        succes = 1;
    catch e
        error('Something went wrong while deleting %s\n%s',name, e.message);
    end
end

end

