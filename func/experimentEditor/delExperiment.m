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
function [ succes ] = delExperiment( name )
%DELEXPERIMENT Summary of this function goes here
%   Detailed explanation goes here
succes = 0;
%% Settings
experimentDir = 'Experiments';
ext = '.mat';
expFile = fullfile(experimentDir, [name ext]);

%% check
[exists, ~, path] = experimentExists(name);
if ~exists
    warning('Experiment (%s) does not exist', name);
end

%% Del
answ = questdlg(sprintf('Are you sure you want to delete %s?', name),'Confirm', 'Yes', 'No', 'No');

if strcmp(answ,'Yes')
    try
        delete(path);
        succes = 1;
    catch e
        error('Something went wrong while deleting %s\n%s',name, e.message);
    end
end

end

