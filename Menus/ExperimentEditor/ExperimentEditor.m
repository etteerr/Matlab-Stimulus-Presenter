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
function varargout = ExperimentEditor(varargin)
% EXPERIMENTEDITOR MATLAB code for ExperimentEditor.fig
%      EXPERIMENTEDITOR, by itself, creates a new EXPERIMENTEDITOR or raises the existing
%      singleton*.
%
%      H = EXPERIMENTEDITOR returns the handle to a new EXPERIMENTEDITOR or the handle to
%      the existing singleton*.
%
%      EXPERIMENTEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPERIMENTEDITOR.M with the given input arguments.
%
%      EXPERIMENTEDITOR('Property','Value',...) creates a new EXPERIMENTEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ExperimentEditor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ExperimentEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ExperimentEditor

% Last Modified by GUIDE v2.5 12-Apr-2016 09:23:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ExperimentEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @ExperimentEditor_OutputFcn, ...
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


% --- Executes just before ExperimentEditor is made visible.
function ExperimentEditor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ExperimentEditor (see VARARGIN)

% Choose default command line output for ExperimentEditor
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Check input
if nargin ~= 4
    delete(hObject);
    error('Invalid usage: ExperimentEditor(name)');
end

name = varargin{1};
if ~ischar(name)
    delete(hObject);
    error('name must be a string');
end

if length(name) < 2
    delete(hObject);
    error('name must be longer than 3 characters');
end

% open experiment
if ~experimentExists(name)
    delete(hObject);
    error('Experiment "%s" does not exist',name);
end

experiment = getExperiment(name);

handles.experiment = experiment;
handles.experiment.name = name;
% experi.name = name;
% experi.datasetDep = {}; % No dataset dependencies yet
% experi.eventDep = {}; % No event dependencies yet
% experi.creator = {}; % Here the blocks with events will be added
% experi.experiment = {}; % Here the generated experiment will be stored (when exp is run)

guidata(hObject, handles);

guiUpdate(handles);

% UIWAIT makes ExperimentEditor wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function guiUpdate(handles)
experi = handles.experiment;
handles.textExperimentName.String = sprintf('Experiment: %s',experi.name);

% Blocks
blocks = experi.creator;
blockList = {};
if ~isempty((blocks))
    for i=1:length(blocks)
        block = blocks{i};
        blockList = [blockList {block.name}];
    end
end
handles.blockList.String = blockList;
if handles.blockList.Value < 1
    handles.blockList.Value = 1;
elseif handles.blockList.Value > length(handles.blockList.String)
    handles.blockList.Value = length(handles.blockList.String);
end
% Selected block info
idx = handles.blockList.Value;
if idx > length(handles.blockList.String) || idx == 0
    idx = length(handles.blockList.String);
    if idx == 0
        idx = 1;
    end
end
infoStr = '';
if ~isempty(blocks)
    block = blocks{idx};
    infoStr = sprintf('Name: %s\n# events: %i', block.name, length(block.events));
end
handles.blockInfo.String = infoStr;


% --- Outputs from this function are returned to the command line.
function varargout = ExperimentEditor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in blockList.
function blockList_Callback(hObject, eventdata, handles)
% hObject    handle to blockList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guiUpdate(handles);
% Hints: contents = cellstr(get(hObject,'String')) returns blockList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from blockList


% --- Executes during object creation, after setting all properties.
function blockList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blockList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in newTrial.
function newTrial_Callback(hObject, eventdata, handles)
% hObject    handle to newTrial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
name = inputdlg('Please enter a name for this block...');
if isempty(name)
    return
end
if length(name{1}) < 2
    waitfor(errordlg('Please enter a name longer than 2'));
    return
end
block = struct;
block.name = name{1};
block.events = {};
block.answers = {}; % This is where the answers to the questionstruct are stored
set(handles.figure1,'Visible','off')
waitfor(ExperimentBlockEditor(block));
set(handles.figure1,'Visible','on')

global experimentlbockeditorreturnvalue
newBlock = experimentlbockeditorreturnvalue;
clear experimentlbockeditorreturnvalue;
if isstruct(newBlock) && isfield(newBlock,'name') && isfield(newBlock,'events')
    handles.experiment.creator = [handles.experiment.creator; {newBlock}];
end
guidata(handles.figure1, handles)
guiUpdate(handles);




% --- Executes on button press in addExisting.
function addExisting_Callback(hObject, eventdata, handles)
% hObject    handle to addExisting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uigetfile('*.mat', 'Open block','Block.mat');
if exist(fullfile(path, file),'file')
    try
        block = load(fullfile(path, file),'block');
        block = block.block;
        if ~isfield(block,'name') || ~isfield(block, 'events')
            error('This is not a block file!')
        end
        handles.experiment.creator = [handles.experiment.creator; {block}];
        guidata(handles.figure1,handles);
        guiUpdate(handles);
        
    catch e
        save(sprintf('memdump_%s.mat',strrep(strrep(datestr(clock), ' ', '_'), ':', '-')));
        errordlg(e.message);
        rethrow(e);
    end
    
end




% --- Executes on button press in removeBlock.
function removeBlock_Callback(hObject, eventdata, handles)
% hObject    handle to removeBlock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.blockList.String)
    return
end
blockname = handles.blockList.String{handles.blockList.Value};
experimentName = handles.experiment.name;
answ = questdlg(sprintf('Are you sure you want to remove %s from %s?', blockname, experimentName),...
    'You sure?,', 'Yes', 'No', 'No');
if strcmp(answ, 'Yes')
    handles.experiment.creator(handles.blockList.Value) = [];
end
handles.blockList.Value = handles.blockList.Value - 1;
guidata(handles.figure1, handles);
guiUpdate(handles);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
try
    updateExperiment(handles.experiment.name, handles.experiment);
catch e
    save(sprintf('memdump_%s.mat',strrep(strrep(datestr(clock), ' ', '_'), ':', '-')));
    try
        global experiment
        experiment = handles.experiment;
        experi = handles.experiment;
        file = [handles.experiment.name '.mat'];
        
    catch e
        warning('Invalid GUI initialization\n%s',e.message);
        delete(hObject);
        return
    end
    save(file, 'experi');
    waitfor(errordlg(sprintf('Oops! Something went wrong while saving!\nWe saved a copy in your current directory (%s)\n%s',...
        file, 'Also we saved it in global experiment, type global experiment to get it in matlab')));
    delete(hObject);
    rethrow(e);
end
delete(hObject);


% --- Executes on button press in buttonUp.
function buttonUp_Callback(hObject, eventdata, handles)
% hObject    handle to buttonUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.blockList.String)
    return
end
loc = handles.blockList.Value;
if loc==1 %Already in top
    return
end
selected = handles.experiment.creator{handles.blockList.Value};
res = handles.experiment.creator;
res(loc) = [];
newOrder = [res(1:loc-2) {selected} res(loc-1:end)];
handles.experiment.creator = newOrder;
handles.blockList.Value = handles.blockList.Value - 1;
guidata(handles.figure1, handles);
guiUpdate(handles);

% --- Executes on button press in buttonDown.
function buttonDown_Callback(hObject, eventdata, handles)
% hObject    handle to buttonDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.blockList.String)
    return
end
loc = handles.blockList.Value;
if loc==length(handles.blockList.String) %Already in top
    return
end
selected = handles.experiment.creator{handles.blockList.Value};
res = handles.experiment.creator;
res(loc) = [];
newOrder = [res(1:loc) {selected} res(loc+1:end)];
handles.experiment.creator = newOrder;
handles.blockList.Value = handles.blockList.Value + 1;
guidata(handles.figure1, handles);
guiUpdate(handles);

% --- Executes on button press in buttonSaveBlock.
function buttonSaveBlock_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSaveBlock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.blockList.String)
    return
end
[file,path] = uiputfile('*.mat', 'Save block as...','Block.mat');
if exist(fullfile(path, file))
    answ = questdlg(sprintf('Do you want to overwrite %s?',file),'Overwrite?!', 'Yes', 'No', 'No');
    if strcmp(answ, 'No')
        waitfor(msgbox('Save aborted...'));
        return
    end
end
block = handles.experiment.creator{handles.blockList.Value};
save(fullfile(path,file),'block');

    


% --- Executes on button press in buttonEdit.
function buttonEdit_Callback(hObject, eventdata, handles)
% hObject    handle to buttonEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.blockList.String)
    return
end
block = handles.experiment.creator{handles.blockList.Value};
set(handles.figure1,'Visible','off')
waitfor(ExperimentBlockEditor(block));
set(handles.figure1,'Visible','on')
global experimentlbockeditorreturnvalue
newBlock = experimentlbockeditorreturnvalue;
clear experimentlbockeditorreturnvalue;
if isstruct(newBlock) && isfield(newBlock,'name') && isfield(newBlock,'events')
    %handles.experiment.creator = [handles.experiment.creator; {newBlock}];
    handles.experiment.creator{handles.blockList.Value} = newBlock;
end
guidata(handles.figure1, handles)
guiUpdate(handles);


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(hObject);


% --- Executes on button press in buttonDuplicate.
function buttonDuplicate_Callback(hObject, eventdata, handles)
% hObject    handle to buttonDuplicate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.blockList.String)
    return
end
experi = handles.experiment;
sel = experi.creator{handles.blockList.Value};
experi.creator = [experi.creator(:); {sel}];
handles.experiment = experi;
guidata(handles.figure1, handles);
guiUpdate(handles);


% --- Executes on button press in buttonRename.
function buttonRename_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.blockList.String)
    return
end
experi = handles.experiment;
newName = inputdlg(sprintf('Please give a new name for this block: %s',experi.creator{handles.blockList.Value}.name));
if isempty(newName)
    return
end
if length(newName{1}) < 3
    errordlg('Name too short!');
    return
end
 experi.creator{handles.blockList.Value}.name = newName{1};
 handles.experiment = experi;
 guidata(handles.figure1, handles);
 guiUpdate(handles);
 
