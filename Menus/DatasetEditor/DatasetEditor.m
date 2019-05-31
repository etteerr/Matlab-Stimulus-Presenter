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
function varargout = DatasetEditor(varargin)
% DATASETEDITOR MATLAB code for DatasetEditor.fig
%      DATASETEDITOR, by itself, creates a new DATASETEDITOR or raises the existing
%      singleton*.
%
%      H = DATASETEDITOR returns the handle to a new DATASETEDITOR or the handle to
%      the existing singleton*.
%
%      DATASETEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATASETEDITOR.M with the given input arguments.
%
%      DATASETEDITOR('Property','Value',...) creates a new DATASETEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DatasetEditor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DatasetEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DatasetEditor

% Last Modified by GUIDE v2.5 12-Apr-2016 09:21:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DatasetEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @DatasetEditor_OutputFcn, ...
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


% --- Executes just before DatasetEditor is made visible.
function DatasetEditor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DatasetEditor (see VARARGIN)

% Choose default command line output for DatasetEditor
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%% Startup
%% Input
try
    if ~(length(varargin) == 2)
        error('Invalid usage of DatasetEditor. A name of the dataset must be passed & if the dataset is new:\nDatasetEditor(name, isNew)\nIf the name is '' and isNew = True: A inputdlg is shown to enter the name.');
    end
    name = varargin{1};
    if ~ischar(name)
        error('Name must be a string!');
    end
    isNew = varargin{2};
    if ~islogical(isNew) && ~isnumeric(isNew)
        error('isNew must be either logical or numeric!');
    end

    if strcmp(name,'') && isNew
        name = inputdlg('Please enter a name for the new dataset','new dataset');
        name = name{1};
    end

    %% Checks
    if datasetExists(name) && isNew
        waitfor(errordlg(sprintf('A dataset with the name %s already exists.','Ow noes!',name)));
        delete(handles.figure1);
        error('Dataset already exists!');
    elseif ~datasetExists(name) && ~isNew
        errordlg(sprintf('Error: Dataset does not exist!'));
        delete(handles.figure1);
        error('Dataset does not exist!');
    end

    %% Create Empty Dataset
    myData = struct;
    if isNew
        createDataset(name,{},'',struct);
    end

    %% GUIDATA
    % files is updated in guiUpdate()
    myData.files = {};
    myData.datadir = 'Data';
    myData.datainfo = 'datainfo.mat';
    myData.databaseName = name;
    myData.saved = 1;
    handles.myData = myData;

    guidata(handles.figure1, handles);
    guiUpdate(handles);
catch e
    save(sprintf('memdump_%s.mat',strrep(strrep(datestr(clock), ' ', '_'), ':', '-')));
    errordlg(sprintf('Error\n:%s',e.message));
    delete(handles.figure1);
    rethrow(e);
end
% UIWAIT makes DatasetEditor wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function guiUpdate(handles)
% Updates from datasetINformation
myData = handles.myData;
if handles.listbox.Value > length(handles.listbox.String) && ~(handles.listbox.Value==1)
    handles.listbox.Value = length(handles.listbox.String);
end
try
    datasetInfo = getDataset(handles.myData.databaseName);
    myData.files = datasetInfo.files;
    handles.listbox.String = myData.files;
    handles.textDatasetName.String = datasetInfo.name;
catch e
    save(sprintf('memdump_%s.mat',strrep(strrep(datestr(clock), ' ', '_'), ':', '-')));
    errordlg(sprintf('Error while updating GUI:\n%s',e.message));
    delete(handles.figure1);
    rethrow(e);
end
handles.myData = myData;
guidata(handles.figure1, handles);

% --- Outputs from this function are returned to the command line.
function varargout = DatasetEditor_OutputFcn(hObject, eventdata, handles) 
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


% --- Executes on button press in buttonClose.
function buttonClose_Callback(hObject, eventdata, handles)
% hObject    handle to buttonClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);


% --- Executes on button press in buttonAdd.
function buttonAdd_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filenames, path] = uigetfile('*.*','Select files...','','Multiselect','on');
% Copy all files to the datastruct directory and add to datainfo
if ~iscell(filenames)
    filenames = {filenames};
end

fullpaths = cell(length(filenames),1);
for fi=1:length(filenames)
    filename = filenames{fi};
    fullpaths{fi} = fullfile(path, filename);
end
try
    [~, completeSucces] = updateDataset(handles.myData.databaseName, fullpaths);
    if ~completeSucces 
        warndlg('There where errors while adding files. Some of them may not have been added.\nSee command window for more information.',...
            'Problems while adding files');
    end
catch e
    save(sprintf('memdump_%s.mat',strrep(strrep(datestr(clock), ' ', '_'), ':', '-')));
    errordlg(sprintf('Update dataset failed:\n%s',e.message));
    rethrow(e);
end
% update GUI
guiUpdate(handles);

% --- Executes on button press in buttonRemove.
function buttonRemove_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRemove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = handles.listbox.String{handles.listbox.Value};
handles.listbox.Value = handles.listbox.Value - 1;
updateDataset(handles.myData.databaseName, {}, {file});
guiUpdate(handles);



% --- Executes on button press in buttonUp.
function buttonUp_Callback(hObject, eventdata, handles)
% hObject    handle to buttonUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = handles.listbox.String{handles.listbox.Value};
loc = handles.listbox.Value;
if loc==1 %Already in top
    return
end
res = handles.listbox.String;
res(loc) = [];
newOrder = [res(1:loc-2); {selected}; res(loc-1:end)];
updateDataset(handles.myData.databaseName,{}, {}, 0, newOrder);
guiUpdate(handles);
handles.listbox.Value = handles.listbox.Value - 1;


% --- Executes on button press in buttonDown.
function buttonDown_Callback(hObject, eventdata, handles)
% hObject    handle to buttonDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = handles.listbox.String{handles.listbox.Value};
loc = handles.listbox.Value;
if loc==length(handles.listbox.String) %Already in bot
    return
end
res = handles.listbox.String;
res(loc) = [];
newOrder = [res(1:loc); {selected}; res(loc+1:end)];
updateDataset(handles.myData.databaseName,{}, {}, 0, newOrder);
guiUpdate(handles);
handles.listbox.Value = handles.listbox.Value + 1;

% --- Executes on button press in buttonTop.
function buttonTop_Callback(hObject, eventdata, handles)
% hObject    handle to buttonTop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = handles.listbox.String{handles.listbox.Value};
loc = handles.listbox.Value;
if loc==1 %Already in top
    return
end
res = handles.listbox.String;
res(loc) = [];
newOrder = [{selected}; res(:)];
updateDataset(handles.myData.databaseName,{}, {}, 0, newOrder);
guiUpdate(handles);
handles.listbox.Value = 1;

% --- Executes on button press in buttonBottom.
function buttonBottom_Callback(hObject, eventdata, handles)
% hObject    handle to buttonBottom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = handles.listbox.String{handles.listbox.Value};
loc = handles.listbox.Value;
if loc==length(handles.listbox.String) %Already in bot
    return
end
res = handles.listbox.String;
res(loc) = [];
newOrder = [res(:); {selected}];
updateDataset(handles.myData.databaseName,{}, {}, 0, newOrder);
guiUpdate(handles);
handles.listbox.Value = length(handles.listbox.String);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
% if strcmp(handles.textSave.String,'Unsaved changes')
%     answer = questdlg('There are unsaved changes! Do you want to save them?','Changes have been made!','Yes','No','Cancel','Cancel');
%     if strcmp(answer, 'Cancel')
%         return
%     end
%     if strcmp(answer,'Yes')
%         buttonSave_Callback(handles.buttonSave, eventdata, handles);
%     end
% end
delete(hObject);


% --- Executes on button press in buttonPurge.
function buttonPurge_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPurge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateDataset(handles.myData.databaseName, {}, {}, 1);
guiUpdate(handles);


% --- Executes on button press in openfileButton.
function openfileButton_Callback(hObject, eventdata, handles)
% hObject    handle to openfileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path = fullfile(handles.myData.datadir,handles.myData.databaseName);
file = handles.listbox.String{handles.listbox.Value};
if exist(fullfile(path,file),'file')
    try
        system(fullfile(path,file));
    catch e
        warning('Failed to open file: %s', e.message);
    end
else
    warning('Failed to open file: File not found.\n%s',fullfile(path,file));
end
