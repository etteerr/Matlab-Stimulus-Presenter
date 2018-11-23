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
    out = 'Start audio'; % The displayed event name
end

function out = getDescription()
    out = 'Loads and starts a sound (mp3, flac etc)';
end

function out = dataType()
    out = 'sound';  % I need sounds (paths to)
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
    %out = 'event.myOwnNameForMyData = howToLoadData(event.WhatINeedData)'; %may be multiline!
% You have acces to:
%   reply: Type is struct. You can leave any data for analysis (write/read)
%   nEvents: scalar containing the number of events in this block (read only)
%   event: A struct containing .name (read only) and .data (read/write).
%   (read/write) for the rest.
%   audioHandles: A local global containing all audio handles in the
%   format: audioHandles(soundID) = psychtoolboxAudioHandle; (used to stop
%   sound by other sound events);
% out = ...
%     ['[aData, Fs] = audioread(event.data);\r\n' ...
%     'if size(aData,1) < 2\r\n' ...
%     '    aData = [aData ; aData];\r\n' ...
%     'end\r\n' ...
%     'aData = transpose(aData); %for some reason...\r\n' ...
%     'hAudio = PsychPortAudio(''Open'' ,[],1,[],Fs,2);\r\n' ...
%     'PsychPortAudio(''FillBuffer'',hAudio,aData, 1);\r\n' ...
%     '%onset = PsychPortAudio(''Start'',hAudio,1,0,0);\r\n' ...
%     'audioHandles(event.id) = hAudio; % creates a local variable for the next audio related function\r\n' ...
%     'event.hAudio = hAudio;\r\nclear aData Fs'];
    out = ['[aData, Fs] = audioread(event.data);\r\n'...
           'if ~(event.stopAfter > length(aData)/Fs)\r\n'...
           'aData = aData(1:int32(event.stopAfter*Fs));\r\n'...
           'end\r\n'...
           'event.hAudio = audioplayer(aData,Fs);\r\n'...
           '[~, name, ext] = fileparts(event.data); strcat(name,ext);  \r\n'...
           'set(event.hAudio,''Tag'',strcat(name,ext));  \r\n'...
           ];
end

function out = getRunFunction()
%event.eventData contains your requested data type from a dataset.
% use \r\n for a new line.
% tip: You can write multiple lines by using:
%     string = ['My long strings first line\r\n', ...
%               'The second line!', ...
%               'Still the second line!\r\nThe Third line!'];
% You have acces to:
%   reply: Type is struct. You can leave any data for analysis
% startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
    %out = 'PsychPortAudio(''Start'',event.hAudio,event.rep,event.delay,event.waitUntillStart, event.stopAfter);\r\nreply.data=event.data;';
    out = ['event.hAudio.play();'...
        'reply.audio = get(event.hAudio, ''Tag''); \r\n'...
        'audio = reply.audio; \r\n'...
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
    q(1).name = 'Event Name';
    q(1).sort = 'edit';
    q(1).data = getEventName();
    q(1).toolTip = 'The name of the event (only for you <3)';
    
    q(2).name = 'Sound ID';
    q(2).sort = 'popupmenu';
    q(2).data = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,...
                 21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40};
    q(2).toolTip = 'The id is needed to stop (or start or resume or what ever) this specific sound in other events';
    
%     q(3).name = 'delay';
%     q(3).sort = 'edit';
%     q(3).data = '0';
%     q(3).toolTip = 'Delay the start of the sound';
    
    q(3).name = '';
    q(3).sort = 'checkbox';
    q(3).data = 'wait for the sound to start';
    q(3).toolTip = '''Freezes'' the program untill the sounds starts playing';
    
    q(4).name = 'Stop sound after';
    q(4).sort = 'edit';
    q(4).data = 'inf';
    q(4).toolTip = 'Stops playing sound after x seconds';
    
%     q(5).name = 'Repeat times';
%     q(5).sort = 'edit';
%     q(5).data = '1';
%     q(5).toolTip = 'Repeats x times, where x == 1 is play once. x may be smaller than 1 to play for example 50% (x==0.5)';
 
    
    out = q; %See eventEditor
end

function out = getEventStruct(data)
% This function MUST return a struct.
% The following struct names are in use and will be overwritten
%   - .name => Contains getEventName()
%   - .data => Contains the requested dataType (reletaive path)
% You can use:
%   - .alias as the displayed name for the event in event editor
%    PsychPortAudio(''Start'',event.hAudio,1,event.delay,event.waitUntillStart, event.stopAfter);
    event = struct;
    event.alias = data(1).String;
    event.id = data(2).Value;
%     event.delay = str2double(data(3).String);
%     if isnan(event.delay)
%         event.delay = 0;
%     end
    event.waitUntillStart = data(3).Value;
    event.stopAfter = str2double(data(4).String);
    if isnan(event.stopAfter)
        event.stofAfter = Inf;
    end
%     event.rep = str2double(data(6).String);
%     if isnan(event.rep)
%         event.rep = 1;
%     end
    out = event;
end