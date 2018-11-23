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
function [ handle ] = initWindowBlack(Message,priority,hideCursor, debug )
%initWindowBlack Create the window and returns it handle
% initWindowBlack([Message][,priority = 2][,hideCursor = 1])
% String Message: a message to be displayed after creating the window
% As not to worry the user
%%%
% Priority, changes priority of the script. (-1 = highest possible, 0 = normal, 1 = high, 2 = max
% (realtime))
% 2 can give rise to system instability

%Black screen
screenColor = [0 0 0];

n = nargin;
switch n
    case 3
        debug = false;
    case 2
        hideCursor = true;
        debug = false;
    case 1
        priority = 1;
        hideCursor = true;
        debug = false;
    case 0
        priority = 1;
        Message = 'Welcome to this experiment!';
        hideCursor = true;
        debug = false;
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

if debug
    handle = Screen('OpenWindow',screenNumber,screenColor, [20 20 800 600]);
else
    handle = Screen('OpenWindow',screenNumber,screenColor);
end

%Hide cursor
if hideCursor && ~debug
    HideCursor;
end

%Set epic priority for epic timings
% Get max
maxp = MaxPriority(handle, 'GetSecs', 'WaitSecs', 'KbCheck', 'KbWait', 'GetChar');
% Set max if requested
if (priority == -1)
    priority = maxp;
end
% Set max if priority is too high
if (priority > maxp)
    priority = maxp;
end
% Set to 0 if debug
if debug
    Priority(0);
else
    Priority(priority);
end

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
    clear all
    clear mex
    clear functions
    error('Keywait function not working correctly. Please try again...');
end
Screen('Flip',handle);
end

