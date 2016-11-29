function [ dataset ] = getTextSet( datasetname )
%GETTEXTSET Returns a cell structure of the contents of given dataset
%   Detailed explanation goes here

directory = 'textData';

%list content
cont = dir(directory);

%iterate and create names
for i=3:length(cont)
    tmp = cont(i).name;
    if (strcmp(tmp(1:length(tmp)-4),datasetname))
        try 
            f = fopen(fullfile(directory, tmp));
            dataset = textscan(f, '%s', 'Delimiter', '\n');
        catch e
            rethrow(e);
        end
    end
end

% get it out of the cell
dataset = dataset{1};
end

