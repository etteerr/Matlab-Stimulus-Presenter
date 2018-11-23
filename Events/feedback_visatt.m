function res = feedback_visatt(varargin)
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
out = 'Feedback'; % The displayed event name
end

function out = getDescription()
out = 'An example of an event';
end

function out = dataType()
out = '';  % I need images (paths to)
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
out =   [...
    'event.feedbackCor      = imread(C:\image); \r\n'...
    'event.feedbackInc      = imread(C:\image); \r\n'...
    'event.feedbackMis      = imread(C:\image); \r\n'...
        ];
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
out =   [...
    'event.index; \r\n'...
    'replyData{eventIter-event.index};                          \r\n'...
    'cue        = replyData{eventIter-event.index(1)}.image;    \r\n'...
    'audTarget  = replyData{eventIter-event.index(2)}.audio;    \r\n'...
    'visTarget  = replyData{eventIter-event.index(3)}.image;    \r\n'...
    'key        = replyData{eventIter-event.index(4)}.key;      \r\n'...
    '                                                           \r\n'... 
    'if  (strcmp(cue,''Small_Fixation.JPG''); reply.cue = "V";         \r\n'...
    'elseif  (strcmp(cue,''Small_Fixation.JPG''); reply.cue = "A";   \r\n'... 
    'end                                                                    \r\n'... 
    'if      strcmp(visTarget,''L.bmp''); reply.visTar = ''L'';             \r\n'... 
    'elseif  strcmp(visTarget,''C.bmp''); reply.visTar = ''C'';             \r\n'... 
    'elseif  strcmp(visTarget,''R.bmp''); reply.visTar = ''R'';             \r\n'... 
    'end  \r\n'... 
    'if     strcmp(audTarget,''500'');      reply.audTar = ''500'';         \r\n'... 
    'elseif strcmp(audTarget,''1000.wav''); reply.audTar = ''1000'';        \r\n'... 
    'elseif strcmp(audTarget,''2000.wav''); reply.audTar = ''2000'';        \r\n'... 
    '  \r\n'... 
    'if strcmp(reply.cue,''V'') && strcmp(reply.visTar, ''L'')    && strcmp(reply.key, ''left'')   ||'... 
    '   strcmp(reply.cue,''V'') && strcmp(reply.visTar, ''C'')    && strcmp(reply.key, ''down'')   ||'... 
    '   strcmp(reply.cue,''V'') && strcmp(reply.visTar, ''R'')    && strcmp(reply.key, ''right'')  ||'... 
    '   strcmp(reply.cue,''A'') && strcmp(reply.audTar, ''500'')  && strcmp(reply.key, ''left'')   ||'... 
    '   strcmp(reply.cue,''A'') && strcmp(reply.visTar, ''1000'') && strcmp(reply.key, ''down'')   ||'... 
    '   strcmp(reply.cue,''A'') && strcmp(reply.visTar, ''2000'') && strcmp(reply.key, ''right'')               \r\n'... 
    'reply.response = ''correct'';   Screen(''PutImage'', windowPtr, event.feedbackCor);                        \r\n'... 
    'elseif isnan(key);                                                                                         \r\n'...
    'reply.response = ''miss'';      Screen(''PutImage'', windowPtr, event.feedbackMis;                         \r\n'...
    'else \r\n feedback = ''Fout!'';                                                                            \r\n'...
    'reply.response = ''incorrect''; Screen(''PutImage'', windowPtr, event.feedbackInc;                         \r\n'... 
    'end                                                                                                        \r\n'...
    'Screen(''Flip'', windowPtr, 0, 0); Screen(''TextSize'',windowPtr, 14);                                     \r\n'...
    '  \r\n'...         
        ];
end

function out = getQuestStruct()
datasets = getDatasets();
questionStruct(1).name = 'Event';
questionStruct(1).sort = 'text';
questionStruct(1).data = 'Cue';

questionStruct(2).name = 'n events back';
questionStruct(2).sort = 'edit';
questionStruct(2).data = '1';

questionStruct(3).name = 'Event';
questionStruct(3).sort = 'text';
questionStruct(3).data = 'Auditory target';

questionStruct(4).name = 'n events back';
questionStruct(4).sort = 'edit';
questionStruct(4).data = '1';

questionStruct(5).name = 'Event';
questionStruct(5).sort = 'text';
questionStruct(5).data = 'Visual target';

questionStruct(6).name = 'n events back';
questionStruct(6).sort = 'edit';
questionStruct(6).data = '1';

questionStruct(7).name = 'Event';
questionStruct(7).sort = 'text';
questionStruct(7).data = 'Response';

questionStruct(8).name = 'n events back';
questionStruct(8).sort = 'edit';
questionStruct(8).data = '1';

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
% The following variables can be used to influence the experiment
% generation.
%         out.generatorRepeat => repeats the previous events
%         out.generatorNBack  => repeats go n back
% previousEvent.index(1) = data(2).String
% previousEvent.index(2) = data(5).String
% previousEvent.index(3) = data(8).String
questIndex = [2 4 6 8];
for i = 1:length(questIndex)
    previousEvent.index(i) = str2double(data(questIndex(i)).String);
end

out = previousEvent;
end