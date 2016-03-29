function [ list ] = getExperiments()
%GETEXPERIMENTS Returns a list of experiments
% [ list ] = getExperiments()
%   Not a lot more to say

%% Settings
experimentDir = 'Experiments';

%% Dir
files = dir(fullfile(experimentDir));

list = {};
for fil=files
    file = fil{1};
    if ~strcmp(file.name,'.') && ~strcmp(file.name,'..') && ~file.isdir
        [ succes, missingEvents, missingDatasets, corrupt  ] = verifyExperiment( name, 1);
        if ~corrupt
            list = [list ;{file.name}];
        end
    end
end

end

