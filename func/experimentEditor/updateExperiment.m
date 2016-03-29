function [ succes ] = updateExperiment( name, newStruct )
%UPDATE Summary of this function goes here
%   [ succes ] = updateExperiment( name, newStruct )
%   newStruct should be the same as the one given with getExperiment(name)
%   Only with edits ;)

[exist, path] = experimentExists(name);
if ~exist
    error('Experiment does not exist: %s', name);
end

experi = newStruct;
try
    save(path, 'experi');
catch e
    error('Error while saving: %s', e.message);
end


end

