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
function varargout = ExperimentStarter(varargin)
% EXPERIMENTSTARTER MATLAB code for ExperimentStarter.fig
%      EXPERIMENTSTARTER, by itself, creates a new EXPERIMENTSTARTER or raises the existing
%      singleton*.
%
%      H = EXPERIMENTSTARTER returns the handle to a new EXPERIMENTSTARTER or the handle to
%      the existing singleton*.
%
%      EXPERIMENTSTARTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPERIMENTSTARTER.M with the given input arguments.
%
%      EXPERIMENTSTARTER('Property','Value',...) creates a new EXPERIMENTSTARTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ExperimentStarter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ExperimentStarter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ExperimentStarter

% Last Modified by GUIDE v2.5 31-Mar-2016 18:42:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ExperimentStarter_OpeningFcn, ...
    'gui_OutputFcn',  @ExperimentStarter_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ExperimentStarter is made visible.
function ExperimentStarter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ExperimentStarter (see VARARGIN)

% Choose default command line output for ExperimentStarter
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
guiUpdate(handles);
% UIWAIT makes ExperimentStarter wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function guiUpdate(handles)
experiments = getExperiments();
if handles.listExperiments.Value > length(experiments)
    if isempty(experiments)
        handles.listExperiments.Value = 1;
    else
        handles.listExperiments.Value = length(experiments);
    end
end
handles.listExperiments.String = experiments;

% --- Outputs from this function are returned to the command line.
function varargout = ExperimentStarter_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in StartExperiment.
function StartExperiment_Callback(hObject, eventdata, handles)
% hObject    handle to StartExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global experimentRunning;
if isempty(handles.listExperiments.String)
    %easter
    waitfor(msgbox('You must first make an experiment! for now, enjoy the color'));
    handles.figure1.Color = [1, 0, 1];
    return
end
name = handles.listExperiments.String{handles.listExperiments.Value};
if ~experimentExists(name)
    waitfor(errordlg('This experiment is not found!'));
    return
end
[ succes, missingEvents, missingDatasets, corrupt, doesNotExist ] = verifyExperiment( name);
if ~succes
    waitfor(errordlg('Experiment failed the validation.\nSee the Command Window for more information.'));
    missingEvents
    missingDatasets
    corrupt
    return
end

% Get GUI data
generatorPackage = struct;

%Set seed
nummer = int64(handles.editSeed.String);
if isempty(nummer)
    waitfor(errordlg('Please enter a seed'));
    return
end
rng(nummer);

try
    % Experiment generic info/settings
    generatorPackage.expData = getExperiment(handles.listExperiments.String{handles.listExperiments.Value});
    generatorPackage.startMessage = handles.editStartMessage.String;
    generatorPackage.startDelay = str2double(handles.editStartDelay.String);
    generatorPackage.interTDelay = str2double(handles.editITrialDelay.String);
    generatorPackage.runMode = handles.runMode.Value - 1;
    % Experiment specific info/settings
    expNotes = handles.editNotes.String;
    subjectId = handles.editSubjectId.String;
catch e
    waitfor(errordlg(sprintf('Error: Invalid input\n%s',e.message)));
    rethrow(e);
end
% Generate experiment
try
    h = waitbar(0,'Generating experiment...');
    [ExperimentData eventNames] = generateExperiment(generatorPackage);
    compileTrialRunner(eventNames);
    initEvents(eventNames);
    clear functions;
catch e
    delete(h);
    waitfor(errordlg(sprintf('Error while generating experiment:\n%s', e.message)));
    rethrow(e);
end
delete(h);
% Run experiment
dateNtime = datestr(datetime);

Screen('Preference', 'SkipSyncTests', 0);
oldLevel = Screen('Preference', 'Verbosity', 0);
try
    hObject.Enable = 'off';
    if experimentRunning
        return;
    end
    experimentRunning = 1;
    hW = initWindowBlack(ExperimentData.preMessage);
catch e
    experimentRunning = 0;
    hObject.Enable = 'on';
    EndofExperiment;
    if strcmp(e.message,'See error message printed above.')
        try
            disp('Warning, skipping sync tests!')
            Screen('Preference', 'SkipSyncTests', 1);
            hW = initWindowBlack(ExperimentData.preMessage);
        catch e
            rethrow(e)
        end
    else
        rethrow(e);
    end
end
%end of init
try
    Data = runExperiment(ExperimentData,hW);
catch e
    hObject.Enable = 'on';
    experimentRunning = 0;
    waitfor(errordlg(sprintf('Error while running the experiment! SORRY! More details in the Command Window')));
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
            msgbox(sprintf('Results saved (and appended) to: %s', fullfile(cd,['Results_' name '.csv'])));
    catch e
        waitfor(errordlg(sprintf('failed to save data! Sorry!')));
    end
    rethrow(e)
end
EndofExperiment(hW,'You have reached the end! Thanks you for participating!');
Screen('Preference', 'Verbosity', oldLevel);
%% Process and save data
data = struct;
dataiter = 0;
for i=1:length(Data)
    blocknr = sprintf('Block %i',i);
    for j=1:length(Data{i})
        dataiter = dataiter + 1;
		% Add extra collums
        data(dataiter).date    = dateNtime;
        data(dataiter).subjectId = subjectId;
		data(dataiter).blocknr = blocknr;
        eventdata = Data{i}{j};
        fnames = fieldnames(eventdata);
        for k=1:length(fnames)
            eval(sprintf('data(dataiter).%s = eventdata.%s;',fnames{k}, fnames{k}));            
        end
    end
end
exportStructToCSV(data,['Results_' name '.csv'],1);
msgbox(sprintf('Results saved (and appended) to: %s', fullfile(cd,['Results_' name '.csv'])));
hObject.Enable = 'on';
experimentRunning = 0;


% --- Executes on selection change in listExperiments.
function listExperiments_Callback(hObject, eventdata, handles)
% hObject    handle to listExperiments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listExperiments contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listExperiments
guiUpdate(handles);

% --- Executes during object creation, after setting all properties.
function listExperiments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listExperiments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ImportExperiment.
function ImportExperiment_Callback(hObject, eventdata, handles)
% hObject    handle to ImportExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editSubjectId_Callback(hObject, eventdata, handles)
% hObject    handle to editSubjectId (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSubjectId as text
%        str2double(get(hObject,'String')) returns contents of editSubjectId as a double


% --- Executes during object creation, after setting all properties.
function editSubjectId_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSubjectId (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editNotes_Callback(hObject, eventdata, handles)
% hObject    handle to editNotes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNotes as text
%        str2double(get(hObject,'String')) returns contents of editNotes as a double


% --- Executes during object creation, after setting all properties.
function editNotes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNotes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editStartMessage_Callback(hObject, eventdata, handles)
% hObject    handle to editStartMessage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStartMessage as text
%        str2double(get(hObject,'String')) returns contents of editStartMessage as a double


% --- Executes during object creation, after setting all properties.
function editStartMessage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStartMessage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editStartDelay_Callback(hObject, eventdata, handles)
% hObject    handle to editStartDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStartDelay as text
%        str2double(get(hObject,'String')) returns contents of editStartDelay as a double


% --- Executes during object creation, after setting all properties.
function editStartDelay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStartDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editITrialDelay_Callback(hObject, eventdata, handles)
% hObject    handle to editITrialDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editITrialDelay as text
%        str2double(get(hObject,'String')) returns contents of editITrialDelay as a double


% --- Executes during object creation, after setting all properties.
function editITrialDelay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editITrialDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function SubjectID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SubjectID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in runMode.
function runMode_Callback(hObject, eventdata, handles)
% hObject    handle to runMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns runMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from runMode


% --- Executes during object creation, after setting all properties.
function runMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to runMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSeed_Callback(hObject, eventdata, handles)
% hObject    handle to editSeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSeed as text
%        str2double(get(hObject,'String')) returns contents of editSeed as a double


% --- Executes during object creation, after setting all properties.
function editSeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
