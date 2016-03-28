%% Main menu program
%   Author: Erwin Diepgrond
%   Email:  e.j.diepgrond@gmail.com
%   Date: 4-1-2016
%   Version 0.5

% Begin of default shizzle

function varargout = start(varargin)
% START MATLAB code for start.fig
%      START, by itself, creates a new START or raises the existing
%      singleton*.
%
%      H = START returns the handle to a new START or the handle to
%      the existing singleton*.
%
%      START('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in START.M with the given input arguments.
%
%      START('Property','Value',...) creates a new START or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before start_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to start_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help start

% Last Modified by GUIDE v2.5 28-Mar-2016 16:50:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @start_OpeningFcn, ...
                   'gui_OutputFcn',  @start_OutputFcn, ...
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
end
% End of default shizzle, start of more default shizzle that may be edited

% --- Executes just before start is made visible.
function start_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to start (see VARARGIN)

    % Choose default command line output for start
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes start wait for user response (see UIRESUME)
    % uiwait(handles.startMenu);
    %%  Add path
    global oldpath
    oldpath = path;
    addpath(genpath('func'));
    addpath(genpath('Menus'));
    %% PsychToolbox
    %It needs to be installed so... Lets check it!
    checkPsychtoolbox;
end

% --- Outputs from this function are returned to the command line.
function varargout = start_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles;
end

function buttonStart_Callback(hObject, eventdata, handles)
    set(handles.startMenu,'Visible','off')
    
    if psychtoolboxExists
        h = ExperimentStarter();
        waitfor(h);
    elseif checkPsychtoolbox %ASk to install, notify that it is needed
        h = ExperimentStarter();
        waitfor(h);
    end
    
    set(handles.startMenu,'Visible','on')
end

function buttonEdit_Callback(hObject, eventdata, handles)
    set(handles.startMenu,'Visible','off')
    waitfor(msgbox('Function not yet implemented','Lazy developer','error'));
    set(handles.startMenu,'Visible','on')
end

function buttonImport_Callback(hObject, eventdata, handles)
    set(handles.startMenu,'Visible','off')
    waitfor(msgbox('Function not yet implemented','Lazy developer','error'));
    set(handles.startMenu,'Visible','on')
end

function buttonBackup_Callback(hObject, eventdata, handles)
    set(handles.startMenu,'Visible','off')
    waitfor(msgbox('Function not yet implemented','Lazy developer','error'));
    set(handles.startMenu,'Visible','on');
end

function buttonExit_Callback(hObject, eventdata, handles)
    %Close childeren
    figs = get(0, 'Children');
    close(figs(figs ~= gcf)) %Close all other figures
    
    close; %Much wow, such sophisticated
end


% --- Executes during object deletion, before destroying properties.
function startMenu_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to startMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Quitting...');
% Reset old path
global oldpath;
path(oldpath);
% and clean the globals
clear global;
end


% --- Executes on button press in buttonDatasetmananger.
function buttonDatasetmananger_Callback(hObject, eventdata, handles)
% hObject    handle to buttonDatasetmananger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.startMenu,'Visible','off')
waitfor(datasetMananger());
set(handles.startMenu,'Visible','on');
end