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
    out = 'Image while KBcheck';
end

function out = getDescription()
    out = 'Show and clear an image while recording reaction time';
end

function out = dataType()
    out = 'image';  % I need images (paths to)
end

function out = init()
	%global error % global error is read when a example returns false
	%error = 'Example must not be included in a running experiemnt!.';
    out = true; %If out == false, the loading of the experiment will be cancled. 
    % No init needed
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
% Screen('Flip', windowPtr [, when] [, dontclear] [, dontsync] [, multiflip]);
     %may be multiline!
     out = [...
        '[event.im, ~, event.didResize] = imageSizeCheck(imread(event.data), windowPtr);          \r\n' ...
        'if length(Screen(''Screens''))>1                                   \r\n' ...
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
% use \r\n for a new line.
% tip: You can write multiple lines by using:
%     string = ['My long strings first line\r\n', ...
%               'The second line!', ...
%               'Still the second line!\r\nThe Third line!'];
   
    out = [...
    'Screen(''PutImage'', windowPtr, event.im);                             \r\n' ...
    '[~,name,ext] = fileparts(event.data);                                  \n\r' ...
    'reply.image = strcat(name,ext);                                        \r\n' ...
    'maxTime     = event.keyTime;                                           \r\n' ...
    'targetKey   = event.key;                                               \r\n' ...
    '[keyIsDown] = KbCheck;                                                 \r\n' ...
    'shown       = 0;                                                       \r\n' ...
    'cleared     = 0;                                                       \r\n' ...
    'while keyIsDown; [keyIsDown] = KbCheck; end;                           \r\n' ...
    '[~, ~, keyCode] = KbCheck;                                             \r\n' ...
    'startCheck   = GetSecs;                                                \r\n' ...
    'while (GetSecs - startCheck) < maxTime && ~any(keyCode(targetKey))     \r\n' ...
        'if shown == 0 && (GetSecs - startCheck) > event.imageOnset         \r\n' ...
             'reply.ImOnset = Screen(''Flip'', windowPtr, 0, 0) - startCheck;    shown = 1;              \r\n' ...
        'end                                                                \r\n' ...
        'if cleared == 0 && (GetSecs - startCheck) > event.imageOffset      \r\n' ...
             'reply.ImOffset = Screen(''Flip'', windowPtr, 0, 0) - startCheck;    cleared = 1;            \r\n' ...
        'end                                                                \r\n' ...
        'if event.waitBar                                                                       \r\n' ...
            'percentage          = (GetSecs - startCheck) / maxTime;                             \r\n' ...
            'event.barDimensions(3)    = event.barHorOffset+round(percentage * event.barWidth); \r\n' ...
            'if (GetSecs - startCheck) > event.imageOnset && (GetSecs - startCheck) < event.imageOffset \r\n' ...
                'Screen(''PutImage'', windowPtr, event.im);                                     \r\n' ...
                'end                                                                            \r\n' ...
            'Screen(''FillRect'' , windowPtr, event.barColor,   event.barDimensions);           \r\n' ...
            'Screen(''FrameRect'', windowPtr, event.frameColor, event.frameDimensions, 3);      \r\n' ...
            'Screen(''Flip'', windowPtr, 0, 0);                                                 \r\n' ...
        'end                                                                \r\n' ...
        '[~, secs, keyCode] = KbCheck;                              \r\n' ...
    'end                                                                    \r\n' ...
        'Screen(''Flip'', windowPtr, 0, 0);                                 \r\n' ...
    'if any(keyCode(targetKey))                                             \r\n' ...
        'reply.RT  = secs - startCheck;                                      \r\n' ...
        'reply.key = KbName(keyCode);                                       \r\n' ...
    'else                                                                   \r\n' ...
        'reply.RT  = NaN;                                                   \r\n' ...
        'reply.key = NaN;                                                   \r\n' ...
    'end                                                                    \r\n' ...
    'reply.didResize = event.didResize; \r\n'...
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
%
% Data is always a string and is always displayed
%
% for sort:
%     use one of these values: 'pushbutton' | 'togglebutton' | 'radiobutton' |
%     'checkbox' | 'edit' | 'text' | 'slider' | 'frame' | 'listbox' | 'popupmenu'.
    q = struct;
    q(1).name = 'Event name';
    q(1).sort = 'edit';
    q(1).data = 'Draw Image';
 
    
%     q(3).name = '';
%     q(3).sort = 'checkbox';
%     q(3).data = 'clear screen';
%     q(3).toolTip = 'If checked: Clears the screen and then shows the image';
    
    q(2).name       = 'Image onset (s)';
    q(2).sort       = 'edit';
    q(2).data       = '0';
    q(2).toolTip    = 'the image will be shown after x seconds';
    
    q(3).name       = 'Image offset (s)';
    q(3).sort       = 'edit';
    q(3).data       = '1';
    q(3).toolTip    = 'the image will be cleared after x seconds';
        
    q(4).name       = 'Specify key';
    q(4).sort       = 'edit';
    q(4).data       = 'space';
    q(4).toolTip    = 'Waits until specified key is pressed. Leave empty for any key, type "space" for spacebar or "return" for enter';
    
    q(5).name      = 'Wait for (s)';
    q(5).sort      = 'edit';
    q(5).data      = 'Inf';
    q(5).tooltip   = 'Waits x seconds for a response before continueing to next event. Waits forever when value is Inf';
    
    q(6).name       = 'Cocktail bar';
    q(6).sort       = 'checkbox';
    q(6).data       = '';
    q(6).tooltop    = 'if enabled, a bar will indicate how much time is left to respond';
     
    q(7).name       = 'Location';
    q(7).sort       = 'popupmenu';
    q(7).data       = {'top','bottom'};
    q(7).tooltop    = 'determines whether the waitbar will be shown at the top or bottom of the screen';
    
    q(8).name = 'Behaviors';
    q(8).sort = 'text';
    q(8).data = 'Select options:';
    out = q; %See eventEditor
end

function out = getEventStruct(answersOfQuestions)
% event.data will be filled with the needed files specified in dataType()
    event = struct;

    % 1. event name
    event.alias = answersOfQuestions(1).String;

    % 2. image onset
    event.imageOnset = eval(answersOfQuestions(2).String);
    
    % 3. image offset    
    event.imageOffset = eval(answersOfQuestions(3).String);
    
    % 4. target key
    event.key = answersOfQuestions(4).String;
    if isempty(event.key)
        event.key = ':';
    elseif ismember(' ', event.key)
        keys = strsplit(event.key);
        event.key = [];
        for i = 1:length(keys)
            event.key = [event.key, KbName(keys(i))];
        end        
    else
        event.key = KbName(event.key);
    end
    
    % 5. max reaction time    
    event.keyTime = answersOfQuestions(5).String;    
    if ischar(event.keyTime)
        event.keyTime = str2double(event.keyTime);
        if isnan(event.keyTime)
            errordlg('Invalid time provided for the Wait for Press function')
            return
        end
    elseif isempty(event.keyTime)
        event.keyTime = inf;
    end
    
    % 6. wait bar
    event.waitBar = answersOfQuestions(6).Value;    
    
    % 7. wait bar position
    event.barLocation = answersOfQuestions(7).String{answersOfQuestions(7).Value}; 
        
    % 8. random order
    event.random = answersOfQuestions(8).String;
    
    out = event; %No other data needed
end