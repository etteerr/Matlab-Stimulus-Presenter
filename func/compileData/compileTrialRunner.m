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
function [ boolSucces ] = compileTrialRunner( varargin )
%% compileTrialRunner( events, template, desti )
%   compileTrialRunner compiles all the working events into a script
%   Compiles all Needed functions into one trial looping script.
%   events:     Cell containing all event names (given by event.m -> getName())
%   template:   string containing the template file, default: 'func/compileData/compileTrialScriptTemplate.m'
%   desti:      The destination script, default: 'func/runTrial.m'
boolSucces = false;

%% input
template = 'func/compileData/compileTrialScriptTemplate_nonLinair.m';
desti = 'func/experiment/runTrial.m';
eventDir = 'Events';

if nargin == 0
    error('Invalid compiler usage')
end
if nargin == 1
    events = varargin{1};
end
if nargin == 2
    template = varargin{2};
end
if nargin == 3
    desti = varargin{3};
end

%% build paths
template = fullfile(cd,template);
desti = fullfile(cd,desti);
eventDir = fullfile(cd,eventDir);

%% checks
% Template must exist. Duhh..
if ~exist(template,'file')
    error('Specified template does not exist: %s', template);
end

if ~exist(eventDir,'dir')
    error('Events directory missing! (%s)', eventDir);
end

if ~iscell(events)
    error('Invalid event list container. Container must be cell.');
end

if length(events) < 1
    error('Invalid event list: List is empty');
end

%% Index events
%Ignores random missing files....
% Errors for missing events are given lateron.
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
                eventNames{it} = res;
                eventFiles{it} = namewe;
            end
        catch
            it = it - 1; % Function did not exist.
        end
    end
end

eventMap = containers.Map(eventNames,eventFiles);

%% Check if all events exist and load them
% Loads all event functions (and thus caches them in memory)
loadFuns = {}; % index linked to eventFuns & eventNames
eventFuns = {}; 
eventNames = {};
load_loadfun = @(name)eval([name, '(''getLoadFun'')']);
load_eventfun = @(name)eval([name, '(''getRunFun'')']);
index = 1;
for eventCell = events
    try
        event = eventCell{1};
        eventFun = eventMap(event);
        % Load
        loadFuns{index} = load_loadfun(eventFun);
        eventFuns{index} = load_eventfun(eventFun);
        eventNames{index} = event;
        % done
        index = index + 1; % If succesfull, increment index
    catch e
        if strcmp(e.identifier,'MATLAB:Containers:Map:NoKey')
            error('Missing event: %s',event)
        else
            rethrow(e)
        end
    end
end
path(prevPath); % Restore path
%% Process/compile
% Open
try
    fTemplate = fopen(template,'r');
    fDesti = fopen(desti,'w+');
catch e
    fprintf('A runtime error occured while compiling (fopen): %s\n',e.message);
    return
end

%write/read & insert
    % We have 3 cases:
    %   \\runload
    %   \\load
    %   \\run
    % when either of these appear in the line, we replace the line
    % with the load&run scrips, load scrips and run scrips respectively
    % Note: This is case Sensitive!
try
    line = fgets(fTemplate); % Get first line
    while ischar(line) % As long as we get text
        line = strrep(line,'%','%%'); % replace comments
        if ~isempty(strfind(line,'\\runload'))
            % ----- Load and run -----
            for i = 1:length(eventNames)
                name = eventNames{i};
                loadFun = loadFuns{i};
                runFun = eventFuns{i};
                fprintf(fDesti,'%% generated script "%s" from %s.m\r\n',name,eventMap(name));
                fprintf(fDesti,'if strcmp(eventName,''%s'')\r\n',name);
                fprintf(fDesti,loadFun);
                fprintf(fDesti,'\r\n'); % an extra new line never hurts
                fprintf(fDesti,runFun);
                fprintf(fDesti,'\r\nend\r\n');
            end
            % ----- load Data -----
        elseif ~isempty(strfind(line,'\\load'))
            for i = 1:length(eventNames)
                name = eventNames{i};
                loadFun = loadFuns{i};
                if ~strcmp(loadFun,'')
                    fprintf(fDesti,'%% generated script "%s" from %s.m\r\n',name,eventMap(name));
                    fprintf(fDesti,'if strcmp(eventName,''%s'')\r\n',name);
                    fprintf(fDesti,loadFun);
                    fprintf(fDesti,'\r\nend\r\n');
                else
                    fprintf(fDesti,'%% event %s has no load function. (%s)\n',name,eventMap(name));
                end
            end
            % ----- run with data -----
        elseif ~isempty(strfind(line,'\\run'))
            for i = 1:length(eventNames)
                name = eventNames{i};
                runFun = eventFuns{i};
                fprintf(fDesti,'%% generated script "%s" from %s.m\r\n',name,eventMap(name));
                fprintf(fDesti,'if strcmp(eventName,''%s'')\r\n',name);
                fprintf(fDesti,runFun);
                fprintf(fDesti,'\r\nend\r\n');
            end
            % ----- print template -----
        else
            fprintf(fDesti,line);
        end
        
        line = fgets(fTemplate); % Get new line
    end
catch e
    fprintf('A runtime error occured while compiling (write/read): %s\n',e.message);
    return
end
boolSucces = true;
fclose(fDesti);
fclose(fTemplate);
end