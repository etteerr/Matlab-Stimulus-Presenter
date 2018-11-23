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
function EndofExperiment(handle, Message, delay )
%ENDOFEXPERIMENT Cleans up the screen after giving the 'Finished' Message
%   Detailed explanation goes here

%Reset priority to normal
Priority(0);
switch nargin
    case 0
        sca; %No handle means we cannot display anything
        ShowCursor;
        return;
    case 1
        Message = 'This is the end of the experiment, press anykey to continue';
        delay = 0;
    case 2
        delay = 0;
end

%clear screen
Screen('Flip',handle);

%Wait one sec to recover
WaitSecs(1);

% Wait secs
WaitSecs(delay);

DrawFormattedText(handle,Message,'center','center',[255 255 255 255]);
DrawFormattedText(handle,'Press anykey to close this screen','center',15,[255 0 0 255]);

Screen('Flip',handle);

%Wait for key
KbWait(-1);

%give them their mouse back!
ShowCursor;

sca; %Screen('CloseAll') (ScreenCloseAll = sca)
end

