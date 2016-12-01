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
function [ handle ] = initWindowBlack(Message,priority,hideCursor )
%initWindowBlack Create the window and returns it handle
% initWindowBlack([Message][,priority = 2][,hideCursor = 1])
% String Message: a message to be displayed after creating the window
% As not to worry the user
%%%
% Priority, changes priority of the script. (0 = normal, 1 = high, 2 = max
% (realtime))

%Black screen
screenColor = [0 0 0];

n = nargin;
switch n
    case 2
        hideCursor = true;
    case 1
        priority = 2;
        hideCursor = true;
    case 0
        priority = 2;
        Message = 'Welcome to this experiment!';
        hideCursor = true;
end
screens = Screen('Screens');
%Get the screen we want
%If external exists, we want the primary screen. For reasons
% screenNumber = max(screens);
if length(screens)>1
    screenNumber = 1;
else
    screenNumber = max(screens);
end
handle = Screen('OpenWindow',screenNumber,screenColor);

%Hide cursor
if hideCursor
    HideCursor;
end

%Set epic priority for epic timings
Priority(2);

%Set text settings
Screen('TextFont',handle, 'Courier New');
Screen('TextSize',handle, 14);
Screen('TextStyle', handle, 1+2);


%Draw (welcome) message in the middle, white
DrawFormattedText(handle,Message,'center','center',[255 255 255 255]);

%Add a extra disclamer
DrawFormattedText(handle,'You can quit this experiment at any time using shift + 2 (@)\nPress anykey to start this experiment',...
    'center',15,[255 0 0 255]);

%flip the screen (to show the text)
Screen('Flip',handle);

[secs] = KbWait(-1);
if secs < 0.1
    error('Keywait function not working correctly. Please try again...');
    clear all
    clear mex
    clear functions
end
Screen('Flip',handle);
end

