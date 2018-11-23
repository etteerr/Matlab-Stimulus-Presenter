function [ SoundDatasetSounds, files ] = loadSoundDatasetSounds( dataset )
%LOADSOUNDDATASETSOUNDS [ SoundDatasetSounds ] = loadSoundDatasetSounds( dataset )
%   Loads sounds from a dataset in an cell array

if ~datasetExists(dataset)
    error('Missing dataset in loadSounds!: %s', dataset);
end

data = getDataset(dataset);
SoundDatasetSounds = {};
[~, Fs] = audioread(data.fullPath{1});
sempai = PsychPortAudio('Open' ,[],1+8,[],Fs,2);
PsychPortAudio('Start', sempai);

for i=1:length(data.fullPath)
    p = data.fullPath{i};
    %Load sound
    [aData, ~] = audioread(p);
    if size(aData,1) < 2
        aData = [aData ; aData]';
    elseif size(aData,2) < 2
        aData = [aData aData];
    end
    aData = transpose(aData); %for some reason...
    sempaiSlave = PsychPortAudio('OpenSlave', sempai, 1, 2);
    
    PsychPortAudio('FillBuffer',sempaiSlave,aData);
    %onset = PsychPortAudio('Start',hAudio,1,0,0);
%     hAudio = audioplayer(aData, Fs);
    SoundDatasetSounds{i} = sempaiSlave;
end
files = data.files;