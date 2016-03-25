clear trial;
trial = {};

clear event;
event = {};
event.type = 'delay';
event.data = 5;

delayEvent = event;
trial(1).event = event;

clear event;
event1 = {};
event1.type = 'sound';
event1.data = 'TheTrail.flac';
event1.id   = 1;
event2 = event1;
event2.id = 2;

trial(2).event = event1;

trial(3).event = delayEvent;

trial(4).event = event2;

trial(5).event = delayEvent;

stopEvent1 = {};
stopEvent1.type = 'endSound';
stopEvent1.id   = 1;
stopEvent2 = stopEvent1;
stopEvent2.id = 2;

trial(6).event = stopEvent1;
trial(7).event = delayEvent;
trial(8).event = stopEvent2;

runTrial(trial,0,0);