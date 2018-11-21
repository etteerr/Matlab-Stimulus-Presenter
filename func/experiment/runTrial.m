%     Copyright (C) 2016  Erwin Diepgrond
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
% 0Template note:
%   \ means insert
% things you can insert:
%   load => Loading script
%   run => running script
%   runload => Run & load script
% format of insertion
%   if event.name == 'eventName'
%       Things done
%   end
%   repeat..
function [ replyData ] = runTrial( events, windowPtr, mode )
% RUNTRIAL Runs the trial according to TrialData and returns Inputdata from
% the subject (or monkey)
%   It needs the handle to the window created by initWindowBlack or
%   initWindowWhite;
%   Mode will be the way the experiment is done.
%   Not yet implemented

%% Speed experiment findings
% A if argument will slow down by >0.001 ms
% using strcmpi instead of integers or floats is NOT slower:
% 1.6703e-05 for 8 compare if's with t==5
% 1.6895e-05 for 8 compare if's with strcmp
% Timing is the same for both (the sd will be something like 0.01e-05)
% Considering this, starting a timer in a loop and in the next iteration
% give a stimuli and the Next iteration get the timer will only add 1ms of
% computation (given that the simuli is loaded in the loop on a SSD)
% This might not be the best, therefore a timing solution loop will be
% made.

%% The kind of loops that are,  will be or should be implementented.
% First off, the the 0 mode called default mode.
% Everything works as expected but there are significant delays in timings.
% This mode can be used when the stimuli are movies (30sec+), when the interval
% between stimuli and timing of the reaction is of no importance.
% Do not use when you want things like (image - 2ms - image) or (image -
% 0ms - sound). It just wont do. 
%% Argument checks and presets
switch(nargin)
    case 2
        mode = 0;
    case 3
        % All is Ok!
    otherwise
        error('incorrect usage of runTrial...');
end
try
    %% initialisation
    data = {};
    nEvents = length(events); % the amount of events (show image, present sound, delay etc)
    audioHandles = zeros(1,40);
    replyData = cell(1,nEvents);

    %% Trial Loops
    switch mode
        %% no preload
        case 0
            replyIter = 1;
            eventIter = 1;
            startTime = GetSecs();
            while eventIter <= nEvents
                % Craete data
                event = events{eventIter};
                reply = struct;
                reply.name = event.name;
                eventName = event.name;
                reply.timeEventStart = GetSecs() - startTime;
                % Run event
% generated script "Show Image" from showImage.m
if strcmp(eventName,'Show Image')
im = imread(event.data);event.im = Screen('MakeTexture', windowPtr, im); 
clear im; 

Screen('DrawTexture', windowPtr, event.im); 
Screen('Flip', windowPtr, 0, double(~event.clear));
[~,name,ext] = fileparts(event.data); 
reply.image = strcat(name,ext); 
image = reply.image; 

end
% generated script "Jitter" from Jitter.m
if strcmp(eventName,'Jitter')

wait = event.range(randi(length(event.range))); WaitSecs(wait); reply.waittime = wait; 

end
% generated script "Clear screen" from clearScreen.m
if strcmp(eventName,'Clear screen')

Screen('Flip',windowPtr, 0, 0); 
Screen('Flip',windowPtr, 0, 1); 

end
% generated script "Show Text" from showTextFromTextSet.m
if strcmp(eventName,'Show Text')
if exist('textDatasets')~=1
    textDatasets={};
end
textDatasets 
event.cdataset 
if isempty(textDatasets)
    textDataset = struct;
    textDataset.name = event.cdataset;
    textDataset.data = getTextSet(event.cdataset);
    textDataset.iter = 1;
    textDatasets{1,1} = event.cdataset;
    textDatasets{2,1} = textDataset;
elseif (sum(strcmp(textDatasets{1,:},event.cdataset))<1)
    textDataset = struct;
    textDataset.name = event.cdataset;
    textDataset.data = getTextSet(event.cdataset);
    textDataset.iter = 1;
    [~,ind] = size(textDatasets);
    textDatasets{1,ind+1} = event.cdataset;
    textDatasets{2,ind+1} = textDataset;
end
[~, n] = size(textDatasets);
for i=1:n
    if (strcmp(textDatasets(1,i),event.cdataset))
        dataset = textDatasets{2,i};
        if (dataset.iter > length(dataset.data))
            if (isempty(dataset.data))
                error('textData is out of stimuli! Dataset too small, change settings or increase datasetsize');
            end
            dataset.iter = 1;
        end
        if (event.random)
            event.line = dataset.data{randi(length(dataset.data))};
        else
            event.line = dataset.data{dataset.iter};
        end
        if (~event.putback)
            dataset.data(dataset.iter) = [];
        else
            dataset.iter = dataset.iter+1;
        end
        textDatasets{2,i} = dataset;
    end
end

reply.line = event.line;DrawFormattedText(windowPtr, reply.line,'center','center',event.color);
Screen('Flip', windowPtr, 0, double(~event.clear));

end
% generated script "WaitForKeyPress" from waitForPress.m
if strcmp(eventName,'WaitForKeyPress')
if length(Screen('Screens'))>1                                  
screenNumber = 1;                                              
else                                                               
screenNumber = max(Screen('Screens'));                       
end                                                                
[screenWidth, screenHeight]=Screen('WindowSize', screenNumber);  
event.barHorOffset    = 15;                                        
event.barWidth        = screenWidth - 2 * event.barHorOffset;      
event.barHeight       = 20;                                        
if strcmp(event.barLocation, 'top')                              
event.barVerOffset    = 10;                                    
event.frameDimensions = [event.barHorOffset, event.barVerOffset, event.barHorOffset+event.barWidth, event.barVerOffset+event.barHeight]; 
else                                                               
event.barVerOffset    = screenHeight - 10;                     
event.frameDimensions = [event.barHorOffset, event.barVerOffset-event.barHeight, event.barHorOffset+event.barWidth, event.barVerOffset]; 
end                                                                
event.barDimensions 	 = event.frameDimensions;                   
event.frameColor      = [230 144 255];                             
event.barColor        = [30 144 255];                              

maxTime     = event.time;                                              
targetKey   = event.key;                                               
[keyIsDown] = KbCheck;                                                 
while keyIsDown; [keyIsDown] = KbCheck; end;                           
[~, secs, keyCode] = KbCheck;                                          
startKbCheck   = GetSecs;                                              
while secs - startKbCheck < maxTime && ~any(keyCode(targetKey))        
if event.waitBar                                                                       
percentage          = (GetSecs - startKbCheck) / maxTime;                          
event.barDimensions(3)    = event.barHorOffset+round(percentage * event.barWidth); 
Screen('FillRect' , windowPtr, event.barColor,   event.barDimensions);           
Screen('FrameRect', windowPtr, event.frameColor, event.frameDimensions, 3);      
Screen('Flip', windowPtr, 0, 1);                                                 
end   
[~, secs, keyCode] = KbCheck;                                      
end                                                                    
Screen('Flip', windowPtr, 0, 0);                                     
if any(keyCode(targetKey))                                             
reply.RT  = secs - startKbCheck;                                   
reply.key = KbName(keyCode);                                       
else                                                                   
reply.RT  = NaN;                                                   
reply.key = NaN;                                                   
end                                                                    

end
% generated script "Ask" from askFeedback.m
if strcmp(eventName,'Ask')
[width, height]=Screen('WindowSize', windowPtr);event.width = width; event.height=height;
Screen('Flip', windowPtr, 0, double(~event.clearscr), 2);
reply.data = Ask(windowPtr, event.quest, event.textcolor,event.bgcolor,event.mode, event.horzpos, event.vertpos, event.fontsize);

end
                % Save
                reply.timeEventEnd = GetSecs() - startTime;
                reply.blockname = event.blockname;
                replyData{replyIter} = reply;
                % Iter
                replyIter = replyIter + 1;
                eventIter = eventIter + 1;
            end
        %% preload  
        case 1
            for iteratorwhichnamecannotbedupe=1:nEvents % load
                event = events{iteratorwhichnamecannotbedupe};
                eventName = event.name;
% generated script "Show Image" from showImage.m
if strcmp(eventName,'Show Image')
im = imread(event.data);event.im = Screen('MakeTexture', windowPtr, im); 
clear im; 

end
% event Jitter has no load function. (Jitter)
% event Clear screen has no load function. (clearScreen)
% generated script "Show Text" from showTextFromTextSet.m
if strcmp(eventName,'Show Text')
if exist('textDatasets')~=1
    textDatasets={};
end
textDatasets 
event.cdataset 
if isempty(textDatasets)
    textDataset = struct;
    textDataset.name = event.cdataset;
    textDataset.data = getTextSet(event.cdataset);
    textDataset.iter = 1;
    textDatasets{1,1} = event.cdataset;
    textDatasets{2,1} = textDataset;
elseif (sum(strcmp(textDatasets{1,:},event.cdataset))<1)
    textDataset = struct;
    textDataset.name = event.cdataset;
    textDataset.data = getTextSet(event.cdataset);
    textDataset.iter = 1;
    [~,ind] = size(textDatasets);
    textDatasets{1,ind+1} = event.cdataset;
    textDatasets{2,ind+1} = textDataset;
end
[~, n] = size(textDatasets);
for i=1:n
    if (strcmp(textDatasets(1,i),event.cdataset))
        dataset = textDatasets{2,i};
        if (dataset.iter > length(dataset.data))
            if (isempty(dataset.data))
                error('textData is out of stimuli! Dataset too small, change settings or increase datasetsize');
            end
            dataset.iter = 1;
        end
        if (event.random)
            event.line = dataset.data{randi(length(dataset.data))};
        else
            event.line = dataset.data{dataset.iter};
        end
        if (~event.putback)
            dataset.data(dataset.iter) = [];
        else
            dataset.iter = dataset.iter+1;
        end
        textDatasets{2,i} = dataset;
    end
end

end
% generated script "WaitForKeyPress" from waitForPress.m
if strcmp(eventName,'WaitForKeyPress')
if length(Screen('Screens'))>1                                  
screenNumber = 1;                                              
else                                                               
screenNumber = max(Screen('Screens'));                       
end                                                                
[screenWidth, screenHeight]=Screen('WindowSize', screenNumber);  
event.barHorOffset    = 15;                                        
event.barWidth        = screenWidth - 2 * event.barHorOffset;      
event.barHeight       = 20;                                        
if strcmp(event.barLocation, 'top')                              
event.barVerOffset    = 10;                                    
event.frameDimensions = [event.barHorOffset, event.barVerOffset, event.barHorOffset+event.barWidth, event.barVerOffset+event.barHeight]; 
else                                                               
event.barVerOffset    = screenHeight - 10;                     
event.frameDimensions = [event.barHorOffset, event.barVerOffset-event.barHeight, event.barHorOffset+event.barWidth, event.barVerOffset]; 
end                                                                
event.barDimensions 	 = event.frameDimensions;                   
event.frameColor      = [230 144 255];                             
event.barColor        = [30 144 255];                              

end
% generated script "Ask" from askFeedback.m
if strcmp(eventName,'Ask')
[width, height]=Screen('WindowSize', windowPtr);event.width = width; event.height=height;
end
                events{iteratorwhichnamecannotbedupe} = event; % save event data (that is loaded for the run fun)
            end
            replyIter = 1;
            eventIter = 1;
            startTime = GetSecs();
            while eventIter <= nEvents % run
                event = events{eventIter};
                % Create data
                reply = struct;
                reply.name = event.name;
                eventName = event.name;
                reply.timeEventStart = GetSecs() - startTime;
                % Run event
% generated script "Show Image" from showImage.m
if strcmp(eventName,'Show Image')
Screen('DrawTexture', windowPtr, event.im); 
Screen('Flip', windowPtr, 0, double(~event.clear));
[~,name,ext] = fileparts(event.data); 
reply.image = strcat(name,ext); 
image = reply.image; 

end
% generated script "Jitter" from Jitter.m
if strcmp(eventName,'Jitter')
wait = event.range(randi(length(event.range))); WaitSecs(wait); reply.waittime = wait; 

end
% generated script "Clear screen" from clearScreen.m
if strcmp(eventName,'Clear screen')
Screen('Flip',windowPtr, 0, 0); 
Screen('Flip',windowPtr, 0, 1); 

end
% generated script "Show Text" from showTextFromTextSet.m
if strcmp(eventName,'Show Text')
reply.line = event.line;DrawFormattedText(windowPtr, reply.line,'center','center',event.color);
Screen('Flip', windowPtr, 0, double(~event.clear));

end
% generated script "WaitForKeyPress" from waitForPress.m
if strcmp(eventName,'WaitForKeyPress')
maxTime     = event.time;                                              
targetKey   = event.key;                                               
[keyIsDown] = KbCheck;                                                 
while keyIsDown; [keyIsDown] = KbCheck; end;                           
[~, secs, keyCode] = KbCheck;                                          
startKbCheck   = GetSecs;                                              
while secs - startKbCheck < maxTime && ~any(keyCode(targetKey))        
if event.waitBar                                                                       
percentage          = (GetSecs - startKbCheck) / maxTime;                          
event.barDimensions(3)    = event.barHorOffset+round(percentage * event.barWidth); 
Screen('FillRect' , windowPtr, event.barColor,   event.barDimensions);           
Screen('FrameRect', windowPtr, event.frameColor, event.frameDimensions, 3);      
Screen('Flip', windowPtr, 0, 1);                                                 
end   
[~, secs, keyCode] = KbCheck;                                      
end                                                                    
Screen('Flip', windowPtr, 0, 0);                                     
if any(keyCode(targetKey))                                             
reply.RT  = secs - startKbCheck;                                   
reply.key = KbName(keyCode);                                       
else                                                                   
reply.RT  = NaN;                                                   
reply.key = NaN;                                                   
end                                                                    

end
% generated script "Ask" from askFeedback.m
if strcmp(eventName,'Ask')
Screen('Flip', windowPtr, 0, double(~event.clearscr), 2);
reply.data = Ask(windowPtr, event.quest, event.textcolor,event.bgcolor,event.mode, event.horzpos, event.vertpos, event.fontsize);

end
                % Save data
                reply.timeEventEnd = GetSecs() - startTime;
                reply.blockname = event.blockname;
                if isfield(event, 'alias')
                    reply.alias = event.alias;
                end
                replyData{replyIter} = reply;
                events{eventIter} = event; % save event data (that is loaded for the run fun)
                % Iters
                replyIter = replyIter + 1;
                eventIter = eventIter + 1;
            end
        otherwise
            error('Unknown trial run mode')
    end

    %% Clean audio handles
    for iteratorwhichnamecannotbedupe=1:length(audioHandles)
        if ~(audioHandles(iteratorwhichnamecannotbedupe)==0)
            PsychPortAudio('Close' , audioHandles(iteratorwhichnamecannotbedupe));
        end
    end

    %% finish data compile
    % nothing to do here
catch e
    % Dump function workspace for later analysis
    save('memdump.mat');
    rethrow(e);
end
end

