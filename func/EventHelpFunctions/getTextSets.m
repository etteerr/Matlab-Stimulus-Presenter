function [ names ] = getTextSets()
%GETTEXTSETS outputs the names of the available text simuli sets
%   Detailed explanation goes here
directory = 'textData';

%list content
cont = dir(directory);

%iterate and create names
names = {};
for i=3:length(cont)
    tmp = cont(i).name;
    if (strcmp(tmp(length(tmp)-3:length(tmp)), '.txt'))
        names = {names{:}, tmp(1:length(tmp)-4)};
    end
end
end

