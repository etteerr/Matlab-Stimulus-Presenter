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
    out = 'Movie'; % The displayed event name
end

function out = getDescription()
    out = 'Movie controls';
end

function out = dataType()
    out = 'video';  % I need videos (paths to)
end

function out = init()
    out = true; %If out == false, the loading of the experiment will be cancled. 
end

function out = enabled()
	out = true; %If this function returns false, it will not be included.
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

%[ moviePtr [duration] [fps] [width] [height] [count] [aspectRatio]]
%    =Screen('OpenMovie', windowPtr, moviefile [, async=0] [, preloadSecs=1]
% [, specialFlags1=0][, pixelFormat=4][, maxNumberThreads=-1][, movieOptions]);
    out = [...
        '[event.pVideo, event.duration] = Screen(''OpenMovie'', windowPtr, event.data);\r\n'...
        'disp(event)\r\n']; %may be multiline!
end

function out = getRunFunction()
%event.eventData contains your requested data type from a dataset.
%windowPtr contains the Psychtoolbox window pointer (handle)
%reply is the struct in which you can create fields to save data
%reply.timeEventStart contains the time passed since the start of the event
%startTime contains the time since the start of the block (excl. loading)
% To change the flow of the events (eg: go 2 events back)
% you can use variable: eventIter
% Also nEvents variable might come in handy
% use \r\n for a new line.
% tip: You can write multiple lines by using:
%     string = ['My long strings first line\r\n', ...
%               'The second line!', ...
%               'Still the second line!\r\nThe Third line!'];

% [droppedframes] = Screen('PlayMovie', moviePtr, rate, [loop], [soundvolume]);
    out = [...
        'while (KbCheck) end\r\n'... 
        '[reply.droppedframes] = Screen(''PlayMovie'', event.pVideo, event.rate, event.loop, event.vol);\r\n'...
        '[~,name,ext] = fileparts(event.data); \n\r' ...
        'reply.movie = strcat(name,ext); \r\n'...
        'reply.start = GetSecs;'...
        'while 1\r\n'...
        '    tex = Screen(''GetMovieImage'', windowPtr, event.pVideo);\r\n'...
        '    if tex<=0\r\n'...
        '        break;\r\n'...
        '    end\r\n'...
        '[reply.keyIsDown, reply.secs, ~, ~] = KbCheck;\r\n'...
        '    if (event.stoponkey && reply.keyIsDown)\r\n'...
        '        break;\r\n'...
        '    end\r\n'...
        'if (event.time && (event.time <= (GetSecs - reply.start)))\r\n'...
        '    break;\r\n'...
        'end\r\n'...
        '    Screen(''DrawTexture'', windowPtr, tex);\r\n'...
        '    Screen(''Flip'', windowPtr);\r\n'...
        '    Screen(''Close'', tex);\r\n'...
        'end\r\n'...
        'reply.stop = GetSecs;'...
        '[reply.droppedframes] = Screen(''PlayMovie'', event.pVideo, 0, event.loop, event.vol);\r\n'...
        ];
end

function out = getQuestStruct()
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
    q = struct;
    
    q(1).name = 'Event name';
    q(1).sort = 'edit';
    q(1).data = 'Play Movie';
    
    q(2).name = 'Playback rate (1 is normal, -1 is revsersed, 0 is stop)';
    q(2).toolTip = 'rate defines the desired playback rate: 0 == Stop playback, 1 == Normal speed forward, -1 == Normal speed backward, ... . Not all movie files allow reverse playback or playback at other rates than normal speed forward.';
    q(2).sort = 'edit';
    q(2).data = '1';
    
    q(3).name = 'Repeat (loop)';
    q(3).sort = 'checkbox';
    q(3).data = 'Loop';
    q(3).toolTip = 'Determines what happens when the movie reaches the end, stop or loop.';
    
    q(4).name = 'Volume (0.0 - 1.0)';
    q(4).sort = 'edit';
    q(4).data = '1.0';
    
    q(5).name = 'Playback for x seconds (0=till end)';
    q(5).sort = 'edit';
    q(5).data = '0';
    
    q(6).name = '';
    q(6).sort = 'checkbox';
    q(6).data = 'Stop on Keypress';
    out = q; %See eventEditor
end

function event = getEventStruct(data)
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
% The following variables can be used to influence the experiment
% generation. 
%         out.generatorRepeat => repeats the previous events
%         out.generatorNBack  => repeats go n back
% event.rate, event.loop, event.vol
    event = struct;
    event.alias = data(1).Answer;
    event.rate = str2double(data(2).Answer);
    event.loop = data(3).Value;
    event.vol = str2double(data(4).Answer);
    event.time = str2double(data(5).Answer);
    event.stoponkey = data(6).Value;
end