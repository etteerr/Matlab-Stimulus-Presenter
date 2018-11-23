function [ data ] = runTrial( events,windowPtr, mode )
%RUNTRIAL Runs the trial according to TrialData and returns Inputdata from
%the subject (or monkey)
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
        %All is Ok!
    otherwise
        error('incorrect usage of runTrial...');
end

%% initialisation
data = {};
nEvents = length(events); %the amount of events (show image, present sound, delay etc)
audioHandles = zeros(1,20);
replyData = struct();

%% Trial Loops
%varius modes will be programmed in switch case, each with their own loop.
%This will remove the need for if's and get the best time result
%Next up: You might not believe it... but if statements are faster than one
%switch statement.... This is a matlab thing...

switch mode
    %% Loop for no preload
    %Use tic toc timing as feedback data in this one
    case 0 %no preload
        tic;
        for i=1:nEvents
            %init loopy loopy stuff
            event = events(i).event;
             %%%%%%%%%%%%%%%%%%Output events%%%%%%%%%%%%%%%%%%%
             % event.data: Contains the data for the output. This will be a
             % path for sound and image, not required for endSound and a
             % time for delay;
             % event.id: Required for sound, it is the id of the sound
             % playing and is required to end that specific sound with
             % endSound.
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type , 'drawImage')
                im = imread(event.data);
                Screen('PutImage', windowPtr, im);
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type , 'show/clear')
                Screen('Flip',windowPtr);
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type , 'drawText')
                 
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type , 'sound')
                [aData, Fs] = audioread(event.data);
                if size(aData,1) < 2
                    aData = [aData ; aData];
                end
                aData = transpose(aData); %for some reason...
                hAudio = PsychPortAudio('Open' ,[],[],[],Fs,2);
                PsychPortAudio('FillBuffer',hAudio,aData);
                onset = PsychPortAudio('Start',hAudio,1,0,0);
                audioHandles(event.id) = hAudio;
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type , 'endSound')
                 PsychPortAudio('Close',audioHandles(event.id));
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type , 'endSoundAll')
                 PsychPortAudio('Close');
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type , 'pauseSound')
                 PsychPortAudio('Stop',audioHandles(event.id));
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type , 'resumeSound')
                 PsychPortAudio('Start',audioHandles(event.id),1,0,0,[],1);
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type , 'delay')
                 WaitSecs(event.data);
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type, 'getTimer')
                 
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type, 'waitForKey')
                 KbPressWait;
             end
             %%%%%%%%%%%%%%INPUT%%%%%%%%%%%%%%%%%%%%%%
             % event.showInput: Show the input on screen as feedback (what
             % they typed).
             % event.question: String to be displayed on screen;
             % event.time: The the the user has to input something.
             % event.color: The color of the question text
             % event.bgcolor: The color of the background of the text;
             % event.fontsize: Well... you should know this one.
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type, 'inputText')
                 
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type, 'inputChar')
                 % Accept keyboard input, echo it to screen.
                 data.replyData(i) = Ask(windowPtr,event.question,[],[],'GetChar',RectLeft,RectTop,event.fontsize); 
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type, 'inputNum')
                 
             end

             data.time(i) = toc;
        end%end of loop
        
       %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       case 1 %preload
           %Load all data
        for i=1:nEvents
            event = events(i).event;
            if strcmpi(event.type , 'drawImage')
                events(i).event.data = imread(event.data);
            end
            if strcmpi(event.type , 'sound')
                [aData, Fs] = audioread(event.data);
                if size(aData,1) < 2
                    aData = [aData ; aData];
                end
                aData = transpose(aData); %for some reason...
                hAudio = PsychPortAudio('Open' ,[],[],[],Fs,2);
                PsychPortAudio('FillBuffer',hAudio,aData);
                %onset = PsychPortAudio('Start',hAudio,1,0,0);
                audioHandles(event.id) = hAudio;
                events(i).event.hAudio = hAudio;
             end
        end
        tic;
        for i=1:nEvents
            %init loopy loopy stuff
            event = events(i).event;
             %%%%%%%%%%%%%%%%%%Output events%%%%%%%%%%%%%%%%%%%
             % event.data: Contains the data for the output. This will be a
             % path for sound and image, not required for endSound and a
             % time for delay;
             % event.id: Required for sound, it is the id of the sound
             % playing and is required to end that specific sound with
             % endSound.
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type , 'drawImage')
                Screen('PutImage', windowPtr, event.data);
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type , 'show/clear')
                Screen('Flip',windowPtr);
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type , 'drawText')
                 
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type , 'sound')
                PsychPortAudio('Start',event.hAudio,1,0,0);
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type , 'endSound')
                 PsychPortAudio('Close',audioHandles(event.id));
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type , 'endSoundAll')
                 PsychPortAudio('Close');
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type , 'pauseSound')
                 PsychPortAudio('Stop',audioHandles(event.id));
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type , 'resumeSound')
                 PsychPortAudio('Start',audioHandles(event.id),1,0,0,[],1);
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type , 'delay')
                 WaitSecs(event.data);
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type, 'getTimer')
                 
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type, 'waitForKey')
                 KbPressWait;
             end
             %%%%%%%%%%%%%%INPUT%%%%%%%%%%%%%%%%%%%%%%
             % event.showInput: Show the input on screen as feedback (what
             % they typed).
             % event.question: String to be displayed on screen;
             % event.time: The the the user has to input something.
             % event.color: The color of the question text
             % event.bgcolor: The color of the background of the text;
             % event.fontsize: Well... you should know this one.
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type, 'inputText')
                 
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type, 'inputChar')
                 % Accept keyboard input, echo it to screen.
                 data.replyData(i) = Ask(windowPtr,event.question,[],[],'GetChar',RectLeft,RectTop,event.fontsize); 
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             if strcmpi(event.type, 'inputNum')
                 
             end

             data.time(i) = toc;
        end%end of loop
        
        
%% Other loops... (TODO)
    otherwise;
end


%% finish data compile
%nothign to do here
end

