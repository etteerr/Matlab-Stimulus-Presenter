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
    out = 'Play dataset sound'; % The displayed event name
end

function out = getDescription()
    out = 'The play function for playing files loaded with LoadSoundDataset';
end

function out = dataType()
    out = '';       % No data required (you may set static data using the questStruct or load)
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
%     event.datasetname = data(1).Answer;
%     %event.sHandle
%     event.repetitions = str2double(data(4).Answer);
%     event.waitForStart = 0;
%     event.stopTime = Inf;
%     % load variables
%     event.putBack = q(5).Value;
%     event.random = q(2).Value;
%     event.soundID = 0;
%     event.soundID = q(4).Value;
    out = [''...
    'if event.random\r\n'...
    '    event.soundID = eval(sprintf(''SoundDataset.%%s.ids(randi(length(SoundDataset.%%s.ids)));'', event.datasetname, event.datasetname));\r\n'...
    'end\r\n'...
    'if ~event.putBack\r\n'...
    '    eval(sprintf(''SoundDataset.%%s.ids(SoundDataset.%%s.ids==event.soundID)= [];'', event.datasetname, event.datasetname));\r\n'...
    'end\r\n'...
    'event.sHandle = eval(sprintf(''SoundDataset.%%s.Sounds{event.soundID};'', event.datasetname));\r\n'...
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
% [SoundDatasetSounds SoundDatasetFiles] = loadSoundDatasetSounds(event.datasetname);
% [SoundDataset.%s.Sounds SoundDataset.%s.Files]
            %         startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
    out = ['reply.soundStartTime = PsychPortAudio(''Start'', event.sHandle, event.repetitions, 0 , event.waitForStart , event.stopTime , 0);\r\n'...
           'reply.soundID = event.soundID;\r\n'...
           '\r\n'];
       %PsychPortAudio(''Stop'', event.sHandle ,1);
%     out = ['event.sHandle.play();\r\n'...
%            'reply.soundID = event.soundID;\r\n'];
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
    % Questions:
    %   - Random => Except (for target, input must be edit '[1 5 7]' to
    %   exclude 1 5 and 7)
    %   - Putback => Can be played once more. Should take from a vector
    %   from 1:length instead of the cell array of handles (dont wanna
    %   loose the handle.
    %       - Reset event
    %   - Repetitions in double
    %   - Dataset
    %   - wait for start?
    %   - stopTime?
    q(1).name = 'Dataset';
    q(1).sort = 'popupmenu';
    q(1).data = getDatasets();
    
    q(2).name = 'Randomness';
    q(2).sort = 'checkbox';
    q(2).data = 'Random sound';
    q(2).toolTip = 'If checked, soundID is ignored';
    
    q(3).name = 'Sound ID (if not random)';
    q(3).sort = 'edit' ;
    q(3).data = '';
    q(3).toolTip = 'ID''s are in order from 1 to n-sounds in order of the dataset';
    
    q(4).name = 'Repetitions';
    q(4).sort = 'edit';
    q(4).data = '1';
    q(4).toolTip = '2 repetitions means play 2x. 0.5 repetitions means play 1/2 of the sound';
    
    q(5).name = 'put Back:';
    q(5).sort = 'checkbox';
    q(5).data = 'put back?';
    q(5).Value = 1;
    out = q; %See eventEditor
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
% PsychPortAudio(''Start'', event.sHandle, event.repetitions, 0 , event.waitForStart , event.stopTime , 0);
    event = struct;
    event.datasetname = data(1).Answer;
    %event.sHandle
    event.repetitions = str2double(data(4).Answer);
    event.waitForStart = 1;
    event.stopTime = Inf;
    % load variables
    event.putBack = data(5).Value;
    event.random = data(2).Value;
    event.soundID = str2double(data(3).Answer);
    out = event;
end