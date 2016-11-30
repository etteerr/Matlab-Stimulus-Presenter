close all
clear all
sca

PsychDefaultSetup(2);

screens = Screen('Screens');

screenNumber = max(screens);
HideCursor;
[Window, windowRect] = PsychImaging('OpenWindow',screenNumber,BlackIndex(screenNumber));

DrawFormattedText(Window,'Welcome to the NHK!')
KbStrokeWait;
ShowCursor;
sca;