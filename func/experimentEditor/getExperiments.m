function [ list ] = getExperiments()
%GETEXPERIMENTS Returns a list of experiments
% [ list ] = getExperiments()
%   Not a lot more to say

%% Settings
experimentDir = 'Experiments';

%% Dir
files = dir(fullfile(experimentDir));

list = {};
for fil=1:length(files)
    file = files(fil);
    if ~strcmp(file.name,'.') && ~strcmp(file.name,'..') && ~file.isdir
        [ succes, missingEvents, missingDatasets, corrupt  ] = verifyExperiment( file.name);
        if ~corrupt
            [~, name , ~] = fileparts(file.name);
            list = [list ;{name}];
        end
    end
end

end

