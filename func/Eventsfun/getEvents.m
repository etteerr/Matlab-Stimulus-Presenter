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
function [eventNames,eventFiles,eventDir, eventMap ] = getEvents()
%GETEVENTS [eventNames,eventFiles,eventDir, eventMap ] = getEvents()
%   Get all enabled events from the eventDir directory (Events)
%   returns all the names of these events, the corresponding files, the
%   directory in which they reside and a eventMap.
%   The eventmap is een Containers.Map structure which uses hashable
%   indexes.
%   You can get a filename for a given eventName the following ways:
%   - Use the eventMap: eventFile = eventMap('eventName');
%   - Use index similarity: eventNames{1} => eventFiles{1};
%   Note: These are the filenames ONLY, the directory is not included.

%% settings
eventDir = 'Events';

files = dir(eventDir);
nFiles = length(files);
eventFiles = {};
eventNames = {};
it = 0;
prevPath = addpath(eventDir); % Add event directory to path (reset in the next section)
for iFile = 1:nFiles
    file = files(iFile);
    namewe = file.name(1:end-2);
    path_ = fullfile(eventDir,file.name);
    if exist(path_,'file')==2 && ~file.isdir && strcmp(file.name(end-1:end),'.m')
        try
            if eval([namewe, '(''enabled'')'])
                it = it + 1;
                res = eval([namewe, '(''getName'')']);
                eventNames{1,it} = res;
                eventFiles{1,it} = namewe;
                
            end
        catch
            it = it - 1; % Function did not exist.
        end
    end
end
path(prevPath);
try
    eventMap = containers.Map(eventNames,eventFiles);
catch e
    warning('eventMap is empty.\n%s\nThe line above should be your MSP root folder containing "Events" directory.\n%s', cd,e.message);
end

end

