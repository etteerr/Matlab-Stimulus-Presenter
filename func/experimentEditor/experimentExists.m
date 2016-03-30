function [ succes, expFile, fullpath ] = experimentExists( name )
%EXPERIMENTEXISTS Checks if an experiment exists with the name [name]
% [ succes, expFile, fullpath ] = experimentExists( name )

%% Settings
experimentDir = 'Experiments';
ext = '.mat';
expFile = fullfile(experimentDir, [name ext]);
fullpath = fullfile(cd,expFile);

%% Check
if ~(exist(expFile,'file'))
    succes = 0;
else
    succes = 1;
end
end
    

