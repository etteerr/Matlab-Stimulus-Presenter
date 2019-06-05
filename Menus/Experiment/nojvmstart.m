%% No jvm gstreamer support mode
fprintf('Initializing session...\n');
cd ..;
cd ..;
cd
% Load paths
addpath(genpath('func'));
addpath(genpath('Menus'));
% Load env
w = warning ('off','all');
load('statesave.mat');
warning(w)
delete 'statesave.mat';

% Init events & generate experiment
try
    fprintf('Generating experiment...\n');
    [ExperimentData eventNames] = generateExperiment(generatorPackage);
    fprintf('Compiling experient...\n');
    compileTrialRunner(eventNames);
    fprintf('Initializing experiment...\n');
    initEvents(eventNames);
    fprintf('Cleaning functions...\n');
    clear functions;
catch e
    memdump;
    fprintf('Error while generating experiment:\n%s', e.message);
    rethrow(e);
end

% message
fprintf('--------------------------------------------------------------------\n');
fprintf('Done loading, if anything goes wrong, close this window to get out!\n');
fprintf('--------------------------------------------------------------------\n');
WaitSecs(1);

%% Run exp.
dateNtime = datestr(datetime);

Screen('Preference', 'SkipSyncTests', 0);
oldLevel = Screen('Preference', 'Verbosity', 0);
try
    if experimentRunning
        warning('Experiment is flagged as running. If this is not the case, type clear global in the command window');
        return;
    end
    experimentRunning = 1;
    hW = initWindowBlack(ExperimentData.preMessage, -1, 1, debug);
catch e
    memdump;
    experimentRunning = 0;
    EndofExperiment;
    if strcmp(e.message,'See error message printed above.')
        try
            disp('Warning, skipping sync tests!')
            Screen('Preference', 'SkipSyncTests', 1);
            hW = initWindowBlack(ExperimentData.preMessage, -1, 1, debug);
        catch e
            rethrow(e)
        end
    else
        rethrow(e);
    end
end
%end of init
try
    Data = runExperiment(ExperimentData,hW, 1);
catch e
    memdump;
    experimentRunning = 0;
    warning('Error while running the experiment! SORRY! More details in the Command Window');
    EndofExperiment;
    try
        %% Process and save data
            data = struct;
            global bakdata;
            Data = bakdata;
            dataiter = 0;
            for i=1:length(Data)
                blocknr = sprintf('Block %i',i);
                for j=1:length(Data{i})
                    dataiter = dataiter + 1;
                    eventdata = Data{i}{j};
                    fnames = fieldnames(eventdata);
                    for k=1:length(fnames)
                        eval(sprintf('data(dataiter).%s = eventdata.%s;',fnames{k}, fnames{k}));            
                    end
		    % Add extra collums
                    data(dataiter).date    = dateNtime;
                    data(dataiter).subjectId = subjectId;
                    data(dataiter).blocknr = blocknr;
                end
            end
            exportStructToCSV(data,['Results_' name '.csv'],1);
            fprintf('Results saved (and appended) to: %s', fullfile(cd,['Results_' name '.csv']));
    catch e
        warning('failed to save data! Sorry!');
        memdump;
    end
    rethrow(e)
end
EndofExperiment(hW,'You have reached the end! Thanks you for participating!');
Screen('Preference', 'Verbosity', oldLevel);

%% Save state en exit
save('returnstate.mat');
fprintf('Press anykey to exit\n');
pause;
exit;