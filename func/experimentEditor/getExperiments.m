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

