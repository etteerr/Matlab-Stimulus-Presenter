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
function varargout = ExperimentMananger(varargin)
% EXPERIMENTMANANGER MATLAB code for ExperimentMananger.fig
%      EXPERIMENTMANANGER, by itself, creates a new EXPERIMENTMANANGER or raises the existing
%      singleton*.
%
%      H = EXPERIMENTMANANGER returns the handle to a new EXPERIMENTMANANGER or the handle to
%      the existing singleton*.
%
%      EXPERIMENTMANANGER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPERIMENTMANANGER.M with the given input arguments.
%
%      EXPERIMENTMANANGER('Property','Value',...) creates a new EXPERIMENTMANANGER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ExperimentMananger_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ExperimentMananger_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ExperimentMananger

% Last Modified by GUIDE v2.5 31-Mar-2016 11:22:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ExperimentMananger_OpeningFcn, ...
                   'gui_OutputFcn',  @ExperimentMananger_OutputFcn, ...
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


% --- Executes just before ExperimentMananger is made visible.
function ExperimentMananger_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ExperimentMananger (see VARARGIN)

% Choose default command line output for ExperimentMananger
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
guiUpdate(handles);

% UIWAIT makes ExperimentMananger wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function guiUpdate(handles)
experiments = getExperiments();
if handles.listbox1.Value > length(experiments)
    if isempty(experiments)
        handles.listbox1.Value = 1;
    else 
        handles.listbox1.Value = length(experiments);
    end
end
handles.listbox1.String = experiments;

% --- Outputs from this function are returned to the command line.
function varargout = ExperimentMananger_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
guiUpdate(handles);

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in newExperiment.
function newExperiment_Callback(hObject, eventdata, handles)
% hObject    handle to newExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
name = inputdlg('Please give a name for this new experiment');
if isempty(name)
    return
end
name = name{1};
if length(name) < 3
    errordlg('Sorry! Name must be longer than 3 characters!');
    return
end
try
    createExperiment(name);
catch e
    errordlg(sprintf('Error while creating experiment:\n%s',e.message));
    rethrow(e);
end
set(handles.figure1,'Visible','off')
waitfor(ExperimentEditor(name));
set(handles.figure1,'Visible','on')

guiUpdate(handles);

% --- Executes on button press in EditExperiment.
function EditExperiment_Callback(hObject, eventdata, handles)
% hObject    handle to EditExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if length(handles.listbox1.String) < 1
    return
end
name = handles.listbox1.String{handles.listbox1.Value};
if ~experimentExists(name)
    errordlg(sprintf('Error! Experiment %s does not exist...', name));
end

set(handles.figure1,'Visible','off')
waitfor(ExperimentEditor(name));
set(handles.figure1,'Visible','on')
guiUpdate(handles);

% --- Executes on button press in DeleteExperiment.
function DeleteExperiment_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if length(handles.listbox1.String) < 1
    return
end
name = handles.listbox1.String{handles.listbox1.Value};
if ~experimentExists(name)
    errordlg(sprintf('Error! Experiment %s does not exist...', name));
end
delExperiment(name);
guiUpdate(handles);

% --- Executes on button press in buttonImport.
function buttonImport_Callback(hObject, eventdata, handles)
% hObject    handle to buttonImport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in exportExperiment.
function exportExperiment_Callback(hObject, eventdata, handles)
% hObject    handle to exportExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
