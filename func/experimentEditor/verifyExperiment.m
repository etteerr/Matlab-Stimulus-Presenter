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
function [ succes, missingEvents, missingDatasets, corrupt, doesNotExist ] = verifyExperiment( name )
%VERIFYE Summary of this function goes here
%   [ succes, missingEvents, missingDatasets, corrupt, doesNotExist ] = verifyExperiment( name)

%%
succes = 1;
missingEvents = {};
missingDatasets = {};
corrupt = 0;
doesNotExist = 0;

%% Check
if ~experimentExists( name )
    doesNotExist = 1;
    return
end

%% Open
try
    data = getExperiment(name);
    if isempty(data)
        corrupt = 1;
        succes = 0;
        return
    end
    
    for database = data.datasetDep
        if sum(strcmp(database{1}, getDatasets())) < 1
            fprintf('%s: missing database %s',name,database{1});
            missingDataset = [missingDatasets; database];
            succes = 0;
        end
    end
%% TODO
%     for event = data.eventDep
%         if sum(strcmp(event{1}, getEvents())) < 1
%             fprintf('%s: missing event %s',name,event{1});
%             missingDataset = [missingDatasets; event];
%         end
%     end
   % warning('Event checker not implemented');
    
catch e
    save(sprintf('memdump_%s.mat',strrep(strrep(datestr(clock), ' ', '_'), ':', '-')));
    warning('Unknown problem: %s', e.message);
    succes = 0;
end


end

