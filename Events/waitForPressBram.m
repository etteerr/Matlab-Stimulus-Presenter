function res = gateway(varargin)
%% The first function is the gateway function, this function can be called by the outside world
%   Various commands/events can pass through this funcion
%   Commands beginning with 'do' indicate that you may do something like
%   installing software. For res, you must return true or false indicating
%   if you can still run this function. If its false it will not include
%   your event in the event list.
%   commands beginning with 'get' will need specific output as requested.
% Commands:
%     doInit:         This will be run before the experiment starts
%     getLoadFun:     should return the function to load your data that needs to be displayed. can be a empty string.
%     getRunFun:      should return the function that does something with the loaded data, like displaying it. can be empty string.
%     getQuestStruct: should return a eventEditor compatible struct. if 0, no questions asked. Empty struct will be passed to getEventStruct
%     getEventStruct: given the resulting questStruct (named answerStruct), create a eventStruct you can use.
%     getName:        should return the name of this event.
%     getDescription: Should return the description for the end user
% notes:
%   the structure containing your data (made in getEventStruct) is always
%   named 'event'. Make sure you use that in getLoadFun and getRunFun.
%
%   The event strucutre contains .eventData  , This variable contains a,
%   from a dataset selected, value. This may be file paths or numbers.
%
%   You may use variables, note that they are only kept within a block.
%
%   Please limit the use of globals, as they may *kugfuckupkug* the timing.
%
%   Before runtime, a script will be made using your strings containing the
%   functions. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables you have acces to in runtime.
%   - nEvents (number) => Contains the number of events in this trial (or block)
%   - replyData (struct) => Here you can store your results.
%   - i (number) => The i'th iteration of this block.


%%If possible, do not edit the following unless you know what it's about!%%

%% handle input
    if nargin <= 0
        error('Invalid usage of the gateway function in a event file. This is problematic!');
    elseif nargin >= 1
        command = varargin{1};
    end
    if nargin == 2
        data = varargin{2};
    end

%% Do what is asked
    switch command
        case 'doInit'
            res = init();
        case 'getLoadFun'
            res = getLoadFunction(); %function to load data (in string format) can be multi line
        case 'getRunFun'
            res = getRunFunction(); %funcion to display (or what ever) data. Also in string format.  can be multi line
        case 'getQuestStruct'
            res = getQuestStruct(); % the optional settings for the user in question struct format. (see ..\Menus\eventEditor.m)
        case 'getEventStruct'
            res = getEventStruct(data); %Based on the answers given by the users, create a event structure.
        case 'getName'
            res = getEventName(); % unique identifier name in string. this will be what the user sees
        case 'dataType'
            res = dataType(); %What type of data does your event use? Images (and thus paths), or numbers?
		case 'enabled'
			res = enabled();
        case 'getDescription'
            res = getDescription();
        otherwise
            error('Unknown command "%s"',command);
    end
end
%% Do edit the following
function out = getEventName()
    out = 'Wait for key press Bram'; % The displayed event name
end

function out = getDescription()
    out = 'The computer waits until the users presses a key';
end

function out = dataType()
    out = '';       % No data required (you may set static data using the questStruct or load)
%     out = 'number'; % I need numbers
%     out = 'string'; % I need strings
%     out = 'image';  % I need images (paths to)
%     out = 'video';  % I need videos (paths to)
%     out = 'sound';  % I need sounds (paths to)
end

function out = init()
    out = true; %If out == false, the loading of the experiment will be cancled. 
end

function out = enabled()
	out = false; %If this function returns false, it will not be included.
end

function out = getLoadFunction()
% event.eventData contains your requested data type from a dataset.
% use \r\n for a new line.
% tip: You can write multiple lines by using:
%     string = ['My long strings first line\r\n', ...
%               'The second line!', ...
%               'Still the second line!\r\nThe Third line!'];
% if out == '', no load function will be written.
% Any change to event will be saved for the runFunction
    out = '';
end

function out = getRunFunction(data)
%event.eventData contains your requested data type from a dataset.
%windowPtr contains the Psychtoolbox window pointer (handle)
%reply is the struct in which you can create fields to save data
%reply.timeEventStart contains the time passed since the start of the event
%startTime contains the time since the start of the block (excl. loading)
% use \r\n for a new line.
% tip: You can write multiple lines by using:
%     string = ['My long strings first line\r\n', ...
%               'The second line!', ...
%               'Still the second line!\r\nThe Third line!'];
    
    out = [...
    'pastEvents = cell2mat(events)                                          \r\n' ...
    '                                                                       \r\n' ...
    'pastEvents.alias                                                       \r\n' ...
    '%ismember({pastEvents.alias},''visual target'')                        \r\n'...
    '[~, name, ext]= fileparts(events{eventIter-3}.data);                   \r\n' ...
    'maxTime     = event.time;                                              \r\n' ...
    'targetKey   = event.key;                                               \r\n' ...
    'startTime   = GetSecs;                                                 \r\n' ...
    '[keyIsDown] = KbCheck;                                                 \r\n' ...
    'while keyIsDown; [keyIsDown] = KbCheck; end;                           \r\n' ...
    '[keyIsDown, ~, keyCode] = KbCheck;                                     \r\n' ...
    'time        = GetSecs - startTime;                                     \r\n' ...
    'while time < maxTime && ~any(keyCode(targetKey))                       \r\n' ...
        '[keyIsDown, secs, keyCode] = KbCheck;                              \r\n' ...
        'time = secs - startTime;                                           \r\n' ...
    'end                                                                    \r\n' ...
    'if any(keyCode(targetKey))                                             \r\n' ...
        'reply.RT  = secs - startTime;                                      \r\n' ...
        'reply.key = KbName(keyCode);                                       \r\n' ...
    'else                                                                   \r\n' ...
        'reply.RT  = NaN;                                                   \r\n' ...
        'reply.key = NaN;                                                   \r\n' ... 
        'Screen(''TextSize'',windowPtr, 40);                                \r\n' ... 
        'feedback = ''Gemist!'';                                            \r\n' ... 
        'DrawFormattedText(windowPtr, feedback,''center'',''center'',[225 0 0]); \r\n' ...
        'Screen(''Flip'', windowPtr, 0, 1);                                 \r\n' ...
    'end                                                                    \r\n' ...
    'Screen(''TextSize'',windowPtr, 14);                                    \r\n' ... 
    ];
end

function out = getQuestStruct()
questionStruct(1).name      = 'event Type';
questionStruct(1).sort      = 'edit';
questionStruct(1).data      = 'Wait for Press';
questionStruct(1).tooltip   = '';

questionStruct(2).name      = 'Specify key';
questionStruct(2).sort      = 'edit';
questionStruct(2).data      = 'space';
questionStruct(2).tooltip   = '';

questionStruct(3).name      = 'Wait for (s)';
questionStruct(3).sort      = 'edit';
questionStruct(3).data      = 'Inf';
questionStruct(3).tooltip   = 'leave empty for any key, type "space" for spacebar or "return" for enter';
 

% questionStruct(1).name = 'event Type';
% questionStruct(1).sort = 'text';
% questionStruct(1).data = 'EventName';
%
% questionStruct(2).name = 'Random';
% questionStruct(2).sort = 'popup';
% questionStruct(2).data = { 'Yes' ; 'No' };
% for sort:
%     use one of these values: 'pushbutton' | 'togglebutton' | 'radiobutton' |
%     'checkbox' | 'edit' | 'text' | 'slider' | 'frame' | 'listbox' | 'popupmenu'.
% If out == 0: No question dialog will popup and no questions are asked.
% getEventStruct will be called regardless.
    out = questionStruct; %See eventEditor
end

function out = getEventStruct(data)
% This function MUST return a struct.
% The following struct names are in use and will be overwritten
%   - .name => Contains getEventName()
%   - .data => Contains the requested dataType (reletaive path)
% You can use:
%   - .alias as the displayed name for the event in event editor
% IN the last place of the struct (if length was 3, the last place will be
% 4) will be the dataset name used (if dataType ~= '')
% You cannot change it, but you can throw an error if you dont want it!
% lenght + 2 will contain whether data selection is random (read only)
% length + 3 will contain whether to put back a selected file after using
% it.
    waitFor        = struct;
    waitFor.key    = data(2).String;
    waitFor.time   = data(3).String;
    if ischar(waitFor.time)
        waitFor.time = str2double(waitFor.time);
        if isnan(waitFor.time)
            errordlg('Invalid time provided for the Wait for Press function')
        end
    elseif isempty(waitFor.time)
        waitFor.time = inf;
    end
    if isempty(waitFor.key)
        waitFor.key = ':';
    elseif ismember(' ',waitFor.key)
        keys = strsplit(waitFor.key);
        waitFor.key = [];
        for i = 1:length(keys)
            waitFor.key = [waitFor.key, KbName(keys(i))];
        end        
    else
        waitFor.key = KbName(waitFor.key);
    end
    out = waitFor;
end