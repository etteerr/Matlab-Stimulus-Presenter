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
function varargout = ExperimentBlockEditor(varargin)
% EXPERIMENTBLOCKEDITOR MATLAB code for ExperimentBlockEditor.fig
%      EXPERIMENTBLOCKEDITOR, by itself, creates a new EXPERIMENTBLOCKEDITOR or raises the existing
%      singleton*.
%
%      H = EXPERIMENTBLOCKEDITOR returns the handle to a new EXPERIMENTBLOCKEDITOR or the handle to
%      the existing singleton*.
%
%      EXPERIMENTBLOCKEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPERIMENTBLOCKEDITOR.M with the given input arguments.
%
%      EXPERIMENTBLOCKEDITOR('Property','Value',...) creates a new EXPERIMENTBLOCKEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ExperimentBlockEditor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ExperimentBlockEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ExperimentBlockEditor

% Last Modified by GUIDE v2.5 30-Mar-2016 14:52:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ExperimentBlockEditor_OpeningFcn, ...
    'gui_OutputFcn',  @ExperimentBlockEditor_OutputFcn, ...
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


% --- Executes just before ExperimentBlockEditor is made visible.
function ExperimentBlockEditor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ExperimentBlockEditor (see VARARGIN)

% Choose default command line output for ExperimentBlockEditor
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%% Checks
if nargin ~= 4
    delete(handles.figure1);
    error('Invalid usage for experimentBlockEditor(blockStruct)');
end

blockData = varargin{1};
if ~isstruct(blockData)
    error('Invalid usage: Input must be a struct!');
end

%% Handle input
if ~isfield(blockData,'name') || ~isfield(blockData, 'events') || ~isfield(blockData, 'answers')
    warning('Missing fields in struct: name OR events OR answers');
    if ~isfield(blockData,'name')
        blockData.name = 'TheMostRandomNameEver';
    end
    if ~isfield(blockData, 'events')
        blockData.events = {};
    end
	if ~isfield(blockData, 'answers')
        blockData.answers = {};
    end
end

handles.blockData = blockData;
guidata(handles.figure1, handles);

% Update GUI
guiUpdate(handles);

% UIWAIT makes ExperimentBlockEditor wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function guiUpdate(handles)
handles.listboxtitle.String = sprintf('Event list: %s', handles.blockData.name);
% Update listbox
listboxdata = {};
if ~isempty(handles.blockData.events)
    for e=handles.blockData.events
        event = e{1};
        if sum(strcmp('alias',fieldnames(event))) == 1
            listboxdata = [listboxdata; {[event.name ': ' event.alias]}];
        else
            listboxdata = [listboxdata; {event.name}];
        end
    end
end
handles.eventList.String = listboxdata;

% Check listbox value does not exceed the # items
if handles.eventList.Value > length(handles.eventList.String)
    handles.eventList.Value = 1;
end

% Update eventSelectorMenu
[eventNames,eventFiles,eventDir, eventMap ] = getEvents();
handles.eventSelectorMenu.String = eventNames;
infoStr = '';
% Check current selected item in listbox (not the dropdown)
% And set the informationText
if ~isempty(handles.eventList.String) && ~isempty(handles.blockData.events)
    idx = handles.eventList.Value;
    event = handles.blockData.events{idx};
    items = fieldnames(event);
    for fn = 1:length(items)
        fname = items{fn};
        infoLine = 0;
        if ~strcmp(fname,'name')
            data = eval(sprintf('event.%s',fname));
            if isnumeric(data)
                infoLine = sprintf('%s:\t%s',fname,num2str(data));
            elseif islogical(data)
                if data
                    infoLine = sprintf('%s:\t%s',fname,'True');
                else
                    infoLine = sprintf('%s:\t%s',fname,'False');
                end
            elseif isstr(data)
                infoLine = sprintf('%s:\t%s',fname,data);
            else
                %Ignore
            end
            infoStr = sprintf('%s\n%s',infoStr,infoLine);
        end
        
    end
    infoStr = sprintf('Name:\t%s%s',event.name,infoStr);
end
infoStr = sprintf('Information:\n\n%s',infoStr);
handles.informationText.String = infoStr;


% --- Outputs from this function are returned to the command line.
function varargout = ExperimentBlockEditor_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in eventList.
function eventList_Callback(hObject, eventdata, handles)
% hObject    handle to eventList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns eventList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from eventList
guiUpdate(handles);

% --- Executes during object creation, after setting all properties.
function eventList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eventList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in eventSelectorMenu.
function eventSelectorMenu_Callback(hObject, eventdata, handles)
% hObject    handle to eventSelectorMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns eventSelectorMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from eventSelectorMenu


% --- Executes during object creation, after setting all properties.
function eventSelectorMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eventSelectorMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonAddEvent.
function buttonAddEvent_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAddEvent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.eventSelectorMenu.String)
    eventname = handles.eventSelectorMenu.String{handles.eventSelectorMenu.Value};
    % create event
    try
        [event, answers] = createEvent(eventname);
    catch e
        waitfor(errordlg(sprintf('Error while evaluating answers: %s',e.message)));
        return
    end
    
    % add event
    if isstruct(event)
        index = length(handles.blockData.events) + 1;
        handles.blockData.events{index} = event;
        handles.blockData.answers{index} = answers;
    else
        if event == 0
            waitfor(msgbox('Operation cancled', 'Event creator'));
        else
            errordlg('Unhandled exception in buttonAddEvent_Callback');
            error('Unhandled exception');
        end
    end
end
guidata(handles.figure1, handles);
guiUpdate(handles);


% --- Executes on button press in buttonRemoveSelected.
function buttonRemoveSelected_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRemoveSelected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.eventList.String)
    return
end
handles.blockData.events(handles.eventList.Value) = [];
handles.blockData.answers(handles.eventList.Value) = [];
guidata(handles.figure1, handles);
guiUpdate(handles);

% --- Executes on button press in buttonDuplicateSelected.
function buttonDuplicateSelected_Callback(hObject, eventdata, handles)
% hObject    handle to buttonDuplicateSelected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.eventList.String)
    return
end
event = handles.blockData.events(handles.eventList.Value);
answers = handles.blockData.answers(handles.eventList.Value);
handles.blockData.events = [handles.blockData.events event];
handles.blockData.answers = [handles.blockData.answers answers];
guidata(handles.figure1, handles);
guiUpdate(handles);

% --- Executes on button press in buttonEditSelected.
function buttonEditSelected_Callback(hObject, eventdata, handles)
% hObject    handle to buttonEditSelected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.eventList.String)
    return
end
% Variable assimilation
index = handles.eventList.Value;
event = handles.blockData.events{index};
questAnsw = handles.blockData.answers{index};

%Edit event
try
    [event, answers] = editEvent(event, questAnsw);
catch e
    waitfor(errordlg(sprintf('Error while evaluating answers: %s',e.message)));
    return
end

% add event
if isstruct(event)
    handles.blockData.events{index} = event;
    handles.blockData.answers{index} = answers;
else
    if event == 0
        waitfor(msgbox('Operation cancled', 'Event creator'));
    else
        errordlg('Unhandled exception in buttonEditSelected_Callback');
        error('Unhandled exception');
    end
end

% Fin
guidata(handles.figure1, handles);
guiUpdate(handles);


% --- Executes on button press in buttonUp.
function buttonUp_Callback(hObject, eventdata, handles)
% hObject    handle to buttonUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
loc = handles.eventList.Value;
if loc==1 %Already in top
    return
end
selected = handles.blockData.events{handles.eventList.Value};
selecteda = handles.blockData.answers{handles.eventList.Value};

res = handles.blockData.events;
resa = handles.blockData.answers;

res(loc) = [];
resa(loc) = [];

newOrder = [res(1:loc-2) {selected} res(loc-1:end)];
newOrdera = [resa(1:loc-2) {selecteda} resa(loc-1:end)];

handles.blockData.events = newOrder;
handles.blockData.answers = newOrdera;

handles.eventList.Value = handles.eventList.Value - 1;

guidata(handles.figure1, handles);
guiUpdate(handles);


% --- Executes on button press in buttonDown.
function buttonDown_Callback(hObject, eventdata, handles)
% hObject    handle to buttonDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
loc = handles.eventList.Value;
if loc==length(handles.eventList.String) %Already in top
    return
end
selected = handles.blockData.events{handles.eventList.Value};
selecteda = handles.blockData.answers{handles.eventList.Value};

res = handles.blockData.events;
resa = handles.blockData.answers;

res(loc) = [];
resa(loc) = [];

newOrder = [res(1:loc) {selected} res(loc+1:end)];
newOrdera = [resa(1:loc) {selecteda} resa(loc+1:end)];

handles.blockData.events = newOrder;
handles.blockData.answers = newOrdera;

handles.eventList.Value = handles.eventList.Value + 1;

guidata(handles.figure1, handles);
guiUpdate(handles);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
global experimentlbockeditorreturnvalue
try

experimentlbockeditorreturnvalue = handles.blockData;
catch
    experimentlbockeditorreturnvalue = -1;
end
delete(hObject);
