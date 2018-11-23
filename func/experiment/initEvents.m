function initEvents( varargin )
%% initEvents( events )
% Calls the init function of all events

%% input
eventDir = 'Events';

if nargin == 0
    error('Invalid compiler usage')
end
if nargin == 1
    events = varargin{1};
end
%% build paths
eventDir = fullfile(cd,eventDir);

%% checks
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

%% Check if all events exist and init them

%load_loadfun = @(name)eval([name, '(''getLoadFun'')']);
%load_eventfun = @(name)eval([name, '(''getRunFun'')']);
init = @(name)eval([name, '(''doInit'')']);
for eventCell = events
    try
        event = eventCell{1};
        eventFun = eventMap(event);
        % init
        if init(eventFun) == 0
            error('Event %s reported init failure', event);
        end
    catch e
        if strcmp(e.identifier,'MATLAB:Containers:Map:NoKey')
            error('Missing event: %s',event)
        else
            rethrow(e);
        end
    end
end
path(prevPath); % Restore path

end

