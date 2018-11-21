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
    out = 'WaitForKeyPress'; % The displayed event name
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
    out = [ ...
        'if length(Screen(''Screens''))>1                                  \r\n' ...
            'screenNumber = 1;                                              \r\n' ...    
        'else                                                               \r\n' ...    
            'screenNumber = max(Screen(''Screens''));                       \r\n' ...    
        'end                                                                \r\n' ...        
        '[screenWidth, screenHeight]=Screen(''WindowSize'', screenNumber);  \r\n' ...
        'event.barHorOffset    = 15;                                        \r\n' ...
        'event.barWidth        = screenWidth - 2 * event.barHorOffset;      \r\n' ...
        'event.barHeight       = 20;                                        \r\n' ...
        'if strcmp(event.barLocation, ''top'')                              \r\n' ...        
            'event.barVerOffset    = 10;                                    \r\n' ...
            'event.frameDimensions = [event.barHorOffset, event.barVerOffset, event.barHorOffset+event.barWidth, event.barVerOffset+event.barHeight]; \r\n' ...
        'else                                                               \r\n' ...
            'event.barVerOffset    = screenHeight - 10;                     \r\n' ...
            'event.frameDimensions = [event.barHorOffset, event.barVerOffset-event.barHeight, event.barHorOffset+event.barWidth, event.barVerOffset]; \r\n' ...            
        'end                                                                \r\n' ...
        'event.barDimensions 	 = event.frameDimensions;                   \r\n' ...
        'event.frameColor      = [230 144 255];                             \r\n' ...
        'event.barColor        = [30 144 255];                              \r\n' ...
        ];
end

function out = getRunFunction()
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
    'maxTime     = event.time;                                              \r\n' ...
    'targetKey   = event.key;                                               \r\n' ...
    '[keyIsDown] = KbCheck;                                                 \r\n' ...
    'while keyIsDown; [keyIsDown] = KbCheck; end;                           \r\n' ...
    '[~, secs, keyCode] = KbCheck;                                          \r\n' ...
    'startKbCheck   = GetSecs;                                              \r\n' ...
    'while secs - startKbCheck < maxTime && ~any(keyCode(targetKey))        \r\n' ...    
        'if event.waitBar                                                                       \r\n' ...
            'percentage          = (GetSecs - startKbCheck) / maxTime;                            \r\n' ...
            'event.barDimensions(3)    = event.barHorOffset+round(percentage * event.barWidth); \r\n' ...                                                                         \r\n' ...
            'Screen(''FillRect'' , windowPtr, event.barColor,   event.barDimensions);           \r\n' ...
            'Screen(''FrameRect'', windowPtr, event.frameColor, event.frameDimensions, 3);      \r\n' ...
            'Screen(''Flip'', windowPtr, 0, 0);                                                 \r\n' ...
        'end   \r\n' ...
        '[~, secs, keyCode] = KbCheck;                                      \r\n' ...
    'end                                                                    \r\n' ...
    'if any(keyCode(targetKey))                                             \r\n' ...
        'reply.RT  = secs - startKbCheck;                                   \r\n' ...
        'reply.key = KbName(keyCode);                                       \r\n' ...
    'else                                                                   \r\n' ...
        'reply.RT  = NaN;                                                   \r\n' ...
        'reply.key = NaN;                                                   \r\n' ...
    'end                                                                    \r\n' ...
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
questionStruct(2).tooltip   = 'leave empty for any key, type "space" for spacebar or "return" for enter';

questionStruct(3).name      = 'Wait for (s)';
questionStruct(3).sort      = 'edit';
questionStruct(3).data      = 'Inf';
questionStruct(3).tooltip   = 'Waits x seconds for a response before continueing to next event. Waits forever when value is Inf';

questionStruct(4).name       = 'Cocktail bar';
questionStruct(4).sort       = 'checkbox';
questionStruct(4).data       = '';
questionStruct(4).tooltop    = 'if enabled, a bar will indicate how much time is left to respond';
   
questionStruct(5).name       = 'Location';
questionStruct(5).sort       = 'popupmenu';
questionStruct(5).data       = {'top','bottom'};
questionStruct(5).tooltop    = 'determines whether the waitbar will be shown at the top or bottom of the screen';
 

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
    
    % 2. target key(s)
    waitFor.key    = data(2).String;
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
    
    % 3. maximum wait time
    waitFor.time   = data(3).String;
    if ischar(waitFor.time)
        waitFor.time = str2double(waitFor.time);
        if isnan(waitFor.time)
            errordlg('Invalid time provided for the Wait for Press function')
            return
        end
    elseif isempty(waitFor.time)
        waitFor.time = inf;
    end
  
     % 4. wait bar
    waitFor.waitBar = data(4).Value;    
    
    % 5. wait bar position
    waitFor.barLocation = data(5).String{data(5).Value}; 
    
    out = waitFor;
end