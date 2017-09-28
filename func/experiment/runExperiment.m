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
function [ data ] = runExperiment( ExperimentData, hWindow, nojvm )
%RUNEXPERIMENT Well... It needs data to do the experiment, like stimuli. It
%needs a handle to a window... And it returns the input data that was
%recorded.
%   Well.... i had a discussion with Jonas. Well.... i dont like timers and
%   i know this works best with a loop. i guess... So here it comes:
%   i will use a for loop (for every trial in ExperimentData, do trial)
%   This way it will go Perfectly. This is because PsychToolbox gives us
%   WaitSec(seconds) which gives us a high accuracy (+- 1ms) timer.
%   It does not matter how long a trial takes, as long as the delay
%   between them is correct. To be more precise: The delay before the
%   trial.
if nargin < 2
    error('Invalid use of runExperiment');
end
if nargin == 2
    nojvm = 0;
end

data = {};
experimentName = ExperimentData.name;
fprintf('---------------------------- Now starting experiment "%s" (%s). ----------------------------\n',experimentName,datestr(datetime,'HH:MM:SS'));

% 0 - Disable all output - Same as using the SuppressAllWarnings flag.
% 1 - Only output critical errors.
% 2 - Output warnings as well.
% 3 - Output startup information and a bit of additional information. This is the default.
% 4 - Be pretty verbose about information and hints to optimize your code and system.
% 5 - Levels 5 and higher enable very verbose debugging output, mostly useful for debugging PTB itself, not generally useful for end-users.


%% adding requirements
    %addpath('func');

%% Preparing experiment data
    nRepeats        = ExperimentData.nRepeats;
    nTrials         = ExperimentData.nTrials;
    trials          = ExperimentData.trials;
    startDelay      = ExperimentData.startDelay;
    interTrialDelay = ExperimentData.interTrialDelay;
    runTrialMode    = ExperimentData.runMode;

%% Hands-off initialisation
    dataIterator = 0;

%% Psychtoolbox init stuff
    InitializePsychSound(1); %init sound stuff (1)=high presision if possible; Not for windows without ASIO audio card
    GetSecs; %load the mex lib (is also a function)
    KbCheck; %does also load mex lib;

%% preflight checks
try
    if length(trials) ~=nTrials
        disp('Warning: nTrials and the amount of trials do not match!');
    end

    if (length(trials) < nTrials)
        error('Error: nTrials is bigger than the amount of trials stored. Aborting...');
    end

    if ~exist('runTrial.m','file')
       if (~nojvm) errordlg('Error! the function runTrial is missing... check that the func folder is placed correctly and that it contains runTrial.m'); end
        error('Error: runTrial missing!');
    end

   
%% runTrials
    %wait start delay before starting
    WaitSecs(ExperimentData.startDelay);
    for repeat=1:nRepeats
        for i=1:nTrials
            dataIterator = dataIterator + 1;
            trial = trials{i};
            feedback = runTrial(trial,hWindow,runTrialMode);
            data{dataIterator} = feedback;
            %TODO: matfile('').feedback = feedback (save data, flush to
            %disk)
            WaitSecs(ExperimentData.interTrialDelay);
        end
    end
%% errorcatching and cleaning
catch e 
    ShowCursor; %Show cursor
    sca; %Close screen
    PsychPortAudio('close'); %close all sounds and shutdown sound driver
    fprintf('---------------------------- Aborted experiment "%s" at %s. ----------------------------\n',experimentName,datestr(datetime,'HH:MM:SS'));
    if (~nojvm) errordlg(e.message); end%give error
    disp(getReport(e));
%    rmpath('func');
    global bakdata;
    bakdata = data;
    rethrow(e);
    %return;
end
%% cleaning
PsychPortAudio('close'); %close all sounds and shutdown sound driver
fprintf('---------------------------- End of experiment "%s" (%s). ----------------------------\n',experimentName,datestr(datetime,'HH:MM:SS'));
%rmpath('func');
end

