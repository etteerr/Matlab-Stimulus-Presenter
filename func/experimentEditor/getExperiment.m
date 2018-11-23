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

