function timeCallbackKeyboardDio
global timerStruct diosessions experimentRunning
FlushEvents('keyDown');
while(experimentRunning)
    k = GetChar();
    if any(k==timerStruct.keys)
        s = diosessions(timerStruct.devname);
        s.outState(timerStruct.ch) = 1;
        s.session.outputSingleScan(s.outState);
        s.outState(timerStruct.ch) = 0;
        pause(20/1000);
        s.session.outputSingleScan(s.outState);
    end

    if any(k==['v' '\'])
        break;
    end
    pause(0.001);
end
end