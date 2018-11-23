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
    out = 'Bind Key to DIO'; % The displayed event name
end

function out = getDescription()
    out = 'Binds a key to a DIO channel';
end

function out = dataType()
    out = '';       % No data required (you may set static data using the questStruct or load)
end

function out = init()
    out = (initDio()==1); %If out == false, the loading of the experiment will be cancled. 
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
    out = [ 'global diosessions timerStruct;\r\n' ...
            'timerStruct = event;\r\n'...
            'timerStruct.go = true;\r\n'...
            'timerStruct.timer = timer(''ExecutionMode'',''singleShot'',''StartDelay'', 1,''TimerFcn'', @(~,~)timeCallbackKeyboardDio);\r\n'...
            'start(timerStruct.timer);\r\n'...
          ];
 %may be multiline!
end

function out = getRunFunction()
%event.eventData contains your requested data type from a dataset.
% use \r\n for a new line.
% tip: You can write multiple lines by using:
%     string = ['My long strings first line\r\n', ...
%               'The second line!', ...
%               'Still the second line!\r\nThe Third line!'];
    out = '';
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
    DioDevices = getConfigDevs();
    channels = {};
    for i=1:length(DioDevices(1).channels)
        ch = DioDevices(1).channels{i};
        channels = [channels {ch.name}];
    end
    
    out = struct; %See eventEditor
    out(1).name = 'Device:';
    out(1).sort = 'popupmenu';
    out(1).data = {DioDevices.name};
    out(1).toolTip = 'Select one of the supported devices';
    
    out(2).name = 'Channel:';
    out(2).sort = 'popupmenu';
    out(2).data = channels;
    out(2).toolTip = 'Select the channel for which the value shall be changed';
    
    out(3).name = 'Key(s) (including spaces):';
    out(3).sort = 'edit';
    out(3).data = 'a';
    out(3).toolTip = 'Typ the keys you want to be detected (Case sensitive) Spaces are included as well!';
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
    event = struct;
    
    DioDevices = getConfigDevs();
    dio = DioDevices(data(1).Value); %GEt selected dio device
    chs = dio.channels;
    ch = data(2).Answer;
    event.alias = ch;
    nOut = 0;
    
    for i=1:length(chs)
        if ~strcmp(DioDevices(1).channels{i}.direction,'InputOnly')
            nOut = nOut + 1;
        end
        if strcmp(DioDevices(1).channels{i}.name, ch)
            event.ch = nOut;
            break;
        end
    end
    event.devname = data(1).Answer;
    event.keys = data(3).String;

    out = event;
end