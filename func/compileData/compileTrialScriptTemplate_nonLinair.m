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
%   \\ means insert
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
                \\runload
                % Save
                reply.timeEventEnd = GetSecs() - startTime;
                reply.blockname = event.blockname;
                if isfield(event, 'alias')
                    reply.alias = event.alias;
                end
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
                \\load
                events{iteratorwhichnamecannotbedupe} = event; % save event data (that is loaded for the run fun)
            end
            replyIter = 1;
            eventIter = 1;
            startTime = GetSecs();
            while eventIter <= nEvents % run
                event = events{eventIter};
                eventTrueIt = eventIter;
                % Create data
                reply = struct;
                reply.name = event.name;
                eventName = event.name;
                reply.timeEventStart = GetSecs() - startTime;
                % Run event
                \\run
                % Save data
                reply.timeEventEnd = GetSecs() - startTime;
                reply.blockname = event.blockname;
                if isfield(event, 'alias')
                    reply.alias = event.alias;
                end
                replyData{replyIter} = reply;
                events{eventTrueIt} = event; % save event data (that is loaded for the run fun)
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
    save(sprintf('memdump_%s.mat',strrep(strrep(datestr(clock), ' ', '_'), ':', '-')));
    try
        assignin('base', 'event_that_caused_error', event);
        openvar('event_that_caused_error');
    catch b
    end
    rethrow(e);
end
end

