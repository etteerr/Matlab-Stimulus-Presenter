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
    out = 'Show Text'; % The displayed event name
end

function out = getDescription()
    out = 'Displays text on screen from a text file';
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
    out = [
    'if exist(''textDatasets'')~=1\r\n'...
    '    textDatasets={};\r\n'...
    'end\r\n'...
    'if isempty(textDatasets)\r\n'...
    '    textDataset = struct;\r\n'...
    '    textDataset.name = event.cdataset;\r\n'...
    '    textDataset.data = getTextSet(event.cdataset);\r\n'...
    '    textDataset.iter = 1;\r\n'...
    '    textDatasets{1,1} = event.cdataset;\r\n'...
    '    textDatasets{2,1} = textDataset;\r\n'...
    'elseif (sum(strcmp(textDatasets{1,:},event.cdataset))<1)\r\n'...
    '    textDataset = struct;\r\n'...
    '    textDataset.name = event.cdataset;\r\n'...
    '    textDataset.data = getTextSet(event.cdataset);\r\n'...
    '    textDataset.iter = 1;\r\n'...
    '    [~,ind] = size(textDatasets);\r\n'...
    '    textDatasets{1,ind+1} = event.cdataset;\r\n'...
    '    textDatasets{2,ind+1} = textDataset;\r\n'...
    'end\r\n'...
    '[~, n] = size(textDatasets);\r\n'...
    'for i=1:n\r\n'...
    '    if (strcmp(textDatasets(1,i),event.cdataset))\r\n'...
    '        dataset = textDatasets{2,i};\r\n'...
    '        if (dataset.iter > length(dataset.data))\r\n'...
    '            if (isempty(dataset.data))\r\n'...
    '                error(''textData is out of stimuli! Dataset too small, change settings or increase datasetsize'');\r\n'...
    '            end\r\n'...
    '            dataset.iter = 1;\r\n'...
    '        end\r\n'...
    '        if (event.random)\r\n'...
    '            event.line = dataset.data{randi(length(dataset.data))};\r\n'...
    '        else\r\n'...
    '            event.line = dataset.data{dataset.iter};\r\n'...
    '        end\r\n'...
    '        if (~event.putback)\r\n'...
    '            dataset.data(dataset.iter) = [];\r\n'...
    '        else\r\n'...
    '            dataset.iter = dataset.iter+1;\r\n'...
    '        end\r\n'...
    '        textDatasets{2,i} = dataset;\r\n'...
    '    end\r\n'...
    'end\r\n'
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

% [nx, ny, textbounds] = DrawFormattedText(win, tstring 
%                         [sx][, sy][, color][, wrapat][, flipHorizontal]
%                         [, flipVertical][, vSpacing][, righttoleft]
%                         [, winRect])
    out = [
        'reply.line = event.line;'...
        'DrawFormattedText(windowPtr, reply.line,''center'',''center'',event.color);\r\n'...
        'Screen(''Flip'', windowPtr, 0, double(~event.clear));\r\n'
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
    out = struct;
    out(1).name = 'Event alias';
    out(1).sort = 'edit';
    out(1).data = 'Show text';
    
    %Gather text datasets
    [datasetnames] = getTextSets();
    if (isempty(datasetnames))
        error('No datasets available in "textData" folder');
    end
    out(2).name = 'Dataset';
    out(2).sort = 'popup';
    out(2).data = datasetnames;
    
    out(3).name = '';
    out(3).sort = 'checkbox';
    out(3).data = 'pick randomly';
    
    out(4).name = 'keep used sentences?';
    out(4).sort = 'checkbox';
    out(4).data = 'putback';
    
    out(5).name = 'color';
    out(5).sort = 'edit';
    out(5).data = '[255 255 255]';
    out(5).toolTip = 'RGB colors, from 0 to 255. first one is red, second is green, third is blue.';
    
    out(6).name = '';
    out(6).sort = 'checkbox';
    out(6).data = 'clear screen';
end

function out = getEventStruct(answer)
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
    out = struct;
    out.alias = answer(1).String;
    out.cdataset = answer(2).Answer;
    out.random = answer(3).Value;
    out.putback = answer(4).Value;
    out.color = eval(answer(5).String);
    out.clear = answer(6).Value;
end