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

