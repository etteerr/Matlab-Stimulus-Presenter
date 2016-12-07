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
    out = 'Ask'; % The displayed event name
end

function out = getDescription()
    out = 'Ask a question, get a reply (mouse, keyboard etc)';
end

function out = dataType()
    out = '';       % No data required (you may set static data using the questStruct or load)
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
% [width, height]=Screen('WindowSize', windowPointerOrScreenNumber [, realFBSize=0]);
    out = ['[width, height]=Screen(''WindowSize'', windowPtr);'...
           'event.width = width; event.height=height;']; %may be multiline!
end

function out = getRunFunction()
%event.eventData contains your requested data type from a dataset.
% use \r\n for a new line.
% tip: You can write multiple lines by using:
%     string = ['My long strings first line\r\n', ...
%               'The second line!', ...
%               'Still the second line!\r\nThe Third line!'];
% Screen('DrawText', windowPtr, text [,x] [,y] [,color] [,backgroundColor] [,yPositionIsBaseline] [,swapTextDirection]);
% Screen('Flip', windowPtr [, when] [, dontclear] [, dontsync] [, multiflip]);
%[newX,newY]=Screen('DrawText', windowPtr, text [,x] [,y] [,color] [,backgroundColor] [,yPositionIsBaseline] [,swapTextDirection]);

    out = ['Screen(''Flip'', windowPtr, 0, double(~event.clearscr), 2);\r\nreply.data = Ask(windowPtr, event.quest, event.textcolor,event.bgcolor,event.mode, ''center'', ''center'');\r\n'...
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
    
    q(1).name = 'Event Alias: ';
    q(1).sort = 'edit';
    q(1).data = '';
    
    q(2).name = 'Question:';
    q(2).sort = 'edit';
    q(2).data = 'Type text to be displayed';
    
    q(3).name = 'Input sort';
    q(3).sort = 'popupmenu';
    q(3).data = { 'GetClicks', 'GetChar', 'GetString' };
    q(3).toolTip = 'GetClicks: Waits for mouseclick, GetChar: Get keyboard input and shows it on screen, GetString: Gets keyboard input';
    
    q(4).name = 'Text Color:';
    q(4).sort = 'edit';
    q(4).data = '[255 255 255]';
    q(4).toolTip = 'RGB triplet: default white. [0 0 0] = black';
    
    q(5).name = 'Background color:';
    q(5).sort = 'edit';
    q(5).data = '[0 0 0]';
    q(5).toolTip = 'RGB triplet: default black. [255 255 255] = white';
    
    q(6).name = '';
    q(6).sort = 'checkbox';
    q(6).data = 'Clear screen';
    out = q; %See eventEditor
end

function out = getEventStruct(q)
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
% reply.data = Ask(windowPtr, event.quest, event.textcolor,event.bgcolor,event.mode);';
    event = struct;
    event.quest = q(2).Answer;
    event.mode = q(3).Answer;
    event.textcolor = eval(q(4).Answer);
    event.bgcolor = eval(q(5).Answer);
    event.clearscr = q(6).Value;
    out = event;
end