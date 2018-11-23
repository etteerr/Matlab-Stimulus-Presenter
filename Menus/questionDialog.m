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
%%
% Added question.Value option to set Value property
function h = eventEditor(questionStruct)
%% eventEditor: creates a GUI for the user to change the given options
% creates an option GUI from a struct using the default matlab
% eventEditorFeedback is the global that contains the answer.
%   eventEditorFeedback Values:
%       struct: Answers to the questions
%       0:      Cancled
%       -1:     Shit happend... (invalid input, etc)
% Returns in global eventEditorFeedback
%   struct with fields
%   - String (handles.item.String)
%   - Value  (handles.item.Value)
%   - Answer (handles.item.String{handles.item.Value})
%   Each index represents the question with the same index
%   Eg.: questionStruct(2) (below) will result in something like this:
%   answer(2).String = 'What the user put in'
% Example of a question struct:
% questionStruct(1).name = 'event Type';
% questionStruct(1).sort = 'text';
% questionStruct(1).data = 'EventName';
% 
% questionStruct(2).name = 'Time';
% questionStruct(2).sort = 'edit';
% questionStruct(2).data = '';
% 
% questionStruct(3).name = 'Random';
% questionStruct(3).sort = 'popup';
% questionStruct(3).data = { 'Yes' ; 'No' };
% questionStruct(3).toolTip = 'Extra mouseover information'
% 
% questionStruct(4).name = 'customName';
% questionStruct(4).sort = 'edit';
% questionStruct(4).data = 'MyCustomName';
% 
% questionStruct(5).name = 'Dataset';
% questionStruct(5).sort = 'popupmenu';
% questionStruct(5).data = {'Dataset1', 'Dataset2', 'Dataset3'};
% 
% questionStruct(6).name = '';
% questionStruct(6).sort = 'checkbox';
% questionStruct(6).data = 'Text?';
% for sort:
%     use one of these values: 'pushbutton' | 'togglebutton' | 'radiobutton' |
%     'checkbox' | 'edit' | 'text' | 'slider' | 'frame' | 'listbox' | 'popupmenu'.

%% Set default feedback (so the caller knows whats'up)
global eventEditorFeedback
eventEditorFeedback = -1; % Error value

%% input check
if nargin == 0
    error('eventEditor: No input recieved. Please read the instructions of eventEditor');
elseif nargin > 1
    error('eventEditor: Invalid input, one argument expected.');
end

%% Check struct
if ~isfield(questionStruct, 'name') || ~isfield(questionStruct, 'sort') || ~isfield(questionStruct, 'data')
    error('The fields "name", "sort" and "Data" are needed');
end

if ~isfield(questionStruct, 'toolTip')
    warning('No toolTip field in the questionStruct. Consider the use of those things!');
    questionStruct(1).toolTip = [];
end

%% SEttings
dsx = 5;  %padding
dsy = 35;  %padding
sx = 145; %size of component (x-axis)
sy = 25;  %size of compotnent (y-axis)
dx = 10;  %spacing on x
dy = 5;   %spacing on y

%% Init figure
h = figure();
h.DockControls = 'off';
h.MenuBar = 'none';
h.Name = 'Figure editor';
h.Resize = 'off';
% Calculate height and width
n = length(questionStruct); %amount if component rows
fx = 2*dsx + 2*sx + dx;
fy = 2*dsy + n * (sy + dy);
h.Position = [h.Position(1) h.Position(2) fx fy];
pos = h.Position;
xstart = dsx;
ystart = pos(4)-dsy;

%% Add component
handles = struct;
i=0;
for question = questionStruct
    % create tooltip string
    toolTip = '';
    if ~isempty(question.toolTip)
        toolTip = question.toolTip;
    end
    
    i = i+1;
    % draw name
    x = xstart;
    y = ystart + -1*(dy + sy) * (i-1);
    handles(i).text = uicontrol('Style','Text',...
                                'String',question.name,...
                                'HorizontalAlignment','right',...
                                'Position',[x y sx sy],...
                                'TooltipString', toolTip);
    % draw option
    if isfield(question,'Value') && isnumeric(question.Value) && ~isempty(question.Value)
        x = xstart + (dx+sx);
        handles(i).quest = uicontrol('Style',question.sort,...
                                    'String',question.data,...
                                    'Position',[x y sx sy],...
                                    'TooltipString', toolTip,...
                                    'Value', question.Value);
    else
        x = xstart + (dx+sx);
        handles(i).quest = uicontrol('Style',question.sort,...
                                    'String',question.data,...
                                    'Position',[x y sx sy],...
                                    'TooltipString', toolTip);
    end
%% Output handle (see function decl.)
end

%% Draw ok / cancel button
i = i+1;
x = xstart;
y = ystart + -1*(dy + sy) * (i-1);
cancel = uicontrol('Style','pushbutton',...
                             'String','Cancel',...
                             'Position',[x y sx sy],...
                              'Callback',@cancel_callback);
x = xstart + (dx+sx);
save = uicontrol('Style','pushbutton',...
                             'String','Save',...
                             'Position',[x y sx sy],...
                             'Callback',@save_callback);
Children.handles = handles;
Children.save = save;
Children.close = cancel;
h.UserData = Children;
end

function save_callback(~,~)
global eventEditorFeedback
h = gcf;

% Gather data
Children = h.UserData;
handles = Children.handles;
answers = struct;
for i=1:length(handles)
    answers(i).String = handles(i).quest.String;
    answers(i).Value = handles(i).quest.Value;
    if iscell(answers(i).String)
        answers(i).Answer = answers(i).String{answers(i).Value};
    else
        answers(i).Answer = answers(i).String;
    end
end

% This does not work... So we use a global
h.UserData = answers;

%Set global...
eventEditorFeedback = answers;

close(gcf)
end

function cancel_callback(~,~)
global eventEditorFeedback
h = questdlg('You really want to discard changes to this event?',...
       'Warning!',...
       'Yes', 'No', 'No');
if strcmp(h,'Yes')
    h = gcf;
    h.UserData = 'cancel';
    
    %Set global
    eventEditorFeedback = 0;
    delete(gcf);
end
end