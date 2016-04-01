function [ experiment ] = getExperiment( name )
%GETEXPERIMENT gets the experiment struct from its file
%   Checks if experiment exists before returning the struct
%% Check
[exist, file] = experimentExists(name);

if ~exist
    error('Experiment does not exist: %s', name);
end

%% Get
load(file);

experiment = {};
try
    experiment = experi;
catch
    warning('Experiment data not found in %s', name)
end

end

