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
function varargout = datasetMananger(varargin)
% DATASETMANANGER MATLAB code for datasetMananger.fig
%      DATASETMANANGER, by itself, creates a new DATASETMANANGER or raises the existing
%      singleton*.
%
%      H = DATASETMANANGER returns the handle to a new DATASETMANANGER or the handle to
%      the existing singleton*.
%
%      DATASETMANANGER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATASETMANANGER.M with the given input arguments.
%
%      DATASETMANANGER('Property','Value',...) creates a new DATASETMANANGER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before datasetMananger_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to datasetMananger_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help datasetMananger

% Last Modified by GUIDE v2.5 28-Mar-2016 17:09:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @datasetMananger_OpeningFcn, ...
                   'gui_OutputFcn',  @datasetMananger_OutputFcn, ...
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


% --- Executes just before datasetMananger is made visible.
function datasetMananger_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to datasetMananger (see VARARGIN)

% Choose default command line output for datasetMananger
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
guiUpdate(handles);

% UIWAIT makes datasetMananger wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function guiUpdate(handles)

try
    handles.listbox.String = getDatasets();
catch e
    memdump;
    waitfor(errordlg('Error while evaluating the datasets'));
    rethrow(e);
end
if handles.listbox.Value > length(handles.listbox.String)
    handles.listbox.Value = length(handles.listbox.String);
end
if handles.listbox.Value < 1
    handles.listbox.Value = 1;
end
guiUpdateInfo(handles);

function guiUpdateInfo(handles)
if length(handles.listbox.String) > 1
    name = handles.listbox.String{handles.listbox.Value};
    try
        info = getDataset(name);
        infostr = sprintf(['Name:\t%s\n' ...
                           '# Files:\t%s\n' ...
                           'Created:\t%s\n' ...
                           'file types:\t%s\n'],...
                           info.name, num2str(info.nFiles), datestr(info.createdDate), info.filetype);
       handles.databaseInfo.String = infostr;
    catch e
        memdump;
        handles.databaseInfo.String = e.message;
        rethrow(e);
    end
end
                       
        

function disableButtons(handles)
handles.buttonEdit.Enable = 'Off';
handles.buttonDelete.Enable = 'Off';
handles.buttonNew.Enable = 'Off';
handles.buttonRename.Enable = 'Off';
handles.buttonValidate.Enable = 'Off';

function enableButtons(handles)
handles.buttonEdit.Enable = 'On';
handles.buttonDelete.Enable = 'On';
handles.buttonNew.Enable = 'On';
handles.buttonRename.Enable = 'On';
handles.buttonValidate.Enable = 'On';

% --- Outputs from this function are returned to the command line.
function varargout = datasetMananger_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox.
function listbox_Callback(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox
guiUpdateInfo(handles)

% --- Executes during object creation, after setting all properties.
function listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonNew.
function buttonNew_Callback(hObject, eventdata, handles)
% hObject    handle to buttonNew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.figure1.Visible = 'Off';
name = inputdlg('Please enter a name');
if ~isempty(name)
    try
        set(handles.figure1,'Visible','off')
        createDataset(name{1}, {}, '', struct);
        waitfor(DatasetEditor(name{1},0));
    catch e
        memdump;
        waitfor(errordlg(sprintf('Error: %s',e.message)));
        set(handles.figure1,'Visible','on')
        guiUpdate(handles);
        rethrow(e);
    end
end
set(handles.figure1,'Visible','on')
guiUpdate(handles);

% --- Executes on button press in buttonEdit.
function buttonEdit_Callback(hObject, eventdata, handles)
% hObject    handle to buttonEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if length(handles.listbox.String) < 1
    return
end
handles.figure1.Visible = 'Off';
name = handles.listbox.String{handles.listbox.Value};
try
    set(handles.figure1,'Visible','off')
    waitfor(DatasetEditor(name,0));
catch e
    memdump;
    waitfor(errordlg(sprintf('Error: %s',e.message)));
    set(handles.figure1,'Visible','on')
    guiUpdate(handles);
    rethrow(e);
end
set(handles.figure1,'Visible','on')
guiUpdate(handles);

% --- Executes on button press in buttonRename.
function buttonRename_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if length(handles.listbox.String) < 1
    return
end
disableButtons(handles);
pname = handles.listbox.String{handles.listbox.Value};
name = inputdlg(sprintf('Give a new name for %s',pname));
if ~isempty(name)
    try
        renameDataset(pname,name{1});
    catch e
        memdump;
        waitfor(errordlg(sprintf('Error: %s',e.message)));
        enableButtons(handles);
        guiUpdate(handles);
        rethrow(e);
    end
end
enableButtons(handles);
guiUpdate(handles);

% --- Executes on button press in buttonValidate.
function buttonValidate_Callback(hObject, eventdata, handles)
% hObject    handle to buttonValidate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if length(handles.listbox.String) < 1
    return
end
disableButtons(handles);
name = handles.listbox.String{handles.listbox.Value};
try
    [ intact, missingFiles, invalidInfoFile, doesNotExist] = validateDataset( name );
    waitfor(msgbox(sprintf('Intact: %i\nmissing files: %i\ninvalid info file: %i\ndoes not exist: %i',...
        intact, missingFiles, invalidInfoFile, doesNotExist )));
catch e
    memdump;
    waitfor(errordlg(sprintf('Error: %s',e.message)));
    enableButtons(handles);
    guiUpdate(handles);
    rethrow(e);
end
guiUpdate(handles);
enableButtons(handles);

% --- Executes on button press in buttonDelete.
function buttonDelete_Callback(hObject, eventdata, handles)
% hObject    handle to buttonDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if length(handles.listbox.String) < 1
    return
end
disableButtons(handles);
name = handles.listbox.String{handles.listbox.Value};
answ = questdlg(sprintf('Are you sure you want to delete %s?',name), 'Delete dataset','Yes', 'No','No');
if strcmp(answ, 'Yes')
    try
        delDataset(name);
    catch e
        memdump;
        waitfor(errordlg(sprintf('Error: %s',e.message)));
        enableButtons(handles);
        guiUpdate(handles);
        rethrow(e);
    end
end
enableButtons(handles);
guiUpdate(handles);
