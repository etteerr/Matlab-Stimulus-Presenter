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

WaitSecs(delay);

DrawFormattedText(handle,Message,'center','center',[255 255 255 255]);
DrawFormattedText(handle,'Press anykey to close this screen','center',0,[255 0 0 255]);

Screen('Flip',handle);

%Wait for key
KbWait(-1);

%give them their mouse back!
ShowCursor;

sca; %Screen('CloseAll') (ScreenCloseAll = sca)
end

