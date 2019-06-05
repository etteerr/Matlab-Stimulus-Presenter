function [eventStruct, eventEditorFeedbackr] = editEvent( eventStruct, prevAnswers )
%editEvent Edits an existing struct with given answers
% Creates a event based on a question diaglog filled with the previous answers and returns the compiled
% event and the eventEditorFeedbackr ( the answers to the questions)
% Throws error on error xD
% returns [0,0] if invalid question stuct was given by the event file or
% operation was cancled


%Get name
eventname = eventStruct.name;


% Gather data
[~,~,eventDir, eventMap ] = getEvents();
eventfilef = fullfile(eventDir,[eventMap(eventname) '.m']);
eventfile = eventMap(eventname);


%Preflight check
if ~exist(eventfilef,'file')
    waitfor(errordlg('Error: Event could not be found! Make sure you didn''t change the Current Directory!'));
    return
end

% Set default return
eventStruct = 0;
eventEditorFeedbackr = 0;

%set path
prevpath = addpath(eventDir);


try
    questStruct = eval(sprintf('%s(''getQuestStruct'')',eventfile));
    if isstruct(questStruct)
        type = eval(sprintf('%s(''dataType'')',eventfile));
        if ~strcmp(type,'')
            % Data is requested!
            l = length(questStruct);
            datasets = getDatasets();
            if isempty(datasets)
                error('No dataset avaible! Please create one before using this event!');
%                     questStruct(l+1).name = 'Dataset settings:';
%                     questStruct(l+1).sort = 'text';
%                     questStruct(l+1).data = 'No datasets available';
            else
                %What dataset?
                questStruct(l+1).name = 'Choose Dataset:';
                questStruct(l+1).sort = 'popupmenu';
                questStruct(l+1).data = datasets;
                %Random?
                questStruct(l+2).name = 'Random selection?';
                questStruct(l+2).sort = 'popupmenu';
                questStruct(l+2).data = {'No', 'Yes'};
                %put back?
                questStruct(l+3).name = 'Put back?';
                questStruct(l+3).sort = 'popupmenu';
                questStruct(l+3).data = {'No', 'Yes'};
                questStruct(l+3).toolTip = 'In dutch, one would say: Met terugleggen. Meaning stimuli can be selected more than once';
            end
        end
        if ~isempty(fieldnames(questStruct))
            % Different from create event, we now update the default values
            % of the question struct to the previous inputted values
            
            %update questStruct
            for i=1:length(prevAnswers)
                questStruct(i).data = prevAnswers(i).String;
                questStruct(i).Value = prevAnswers(i).Value;
            end
            
            
            waitfor(questionDialog(questStruct));
            global eventEditorFeedback
            if isstruct(eventEditorFeedback)
                answers = eventEditorFeedback;
                % We got our answers. Use the add answer stuff
                if ~strcmp(type,'')
                    % Data is requested!
                    dataset = answers(l+1).Answer;
                    random = answers(l+2).Value;
                    putBack = answers(l+3).Value;
                end
                eventStruct = eval(sprintf('%s(''getEventStruct'',answers)',eventfile));
                if ~strcmp(type,'')
                    eventStruct.dataset = dataset;
                    eventStruct.randomData = random-1;
                    eventStruct.putBack = putBack-1;
                end
                % event.name = the name given by event('getName')
                % event.alias is displayed if it exist
                eventStruct.name = eval(sprintf('%s(''getName'')',eventfile));
                eventEditorFeedbackr = eventEditorFeedback;
            end
        end
    else
        warining('%s gave an invalid thing for getQuestStruct', eventname);
    end

catch e
    % wait with error and clean 
    memdump;
    path(prevpath);
    rethrow(e);
end

%clean
path(prevpath);

end

